import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:appkilosremitidos/core/providers/auth_provider.dart';
import 'package:appkilosremitidos/core/providers/material_pesca_provider.dart';
import 'package:appkilosremitidos/models/material_pesca.dart';
import 'package:appkilosremitidos/screens/material_pesca/widgets/form_fields.dart';

class MaterialPescaFormScreen extends StatefulWidget {
  final MaterialPesca data;

  const MaterialPescaFormScreen({super.key, required this.data});

  @override
  State<MaterialPescaFormScreen> createState() =>
      _MaterialPescaFormScreenState();
}

class _MaterialPescaFormScreenState extends State<MaterialPescaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late MaterialPesca _formData;
  final _formFields = MaterialPescaFormFields();

  @override
  void initState() {
    super.initState();
    _formData = widget.data;
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final provider = Provider.of<MaterialPescaProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      setState(() => _formFields.isSaving = true);

      // Primero guardamos localmente con estado no sincronizado
      _formData = _formData.copyWith(
        tieneRegistro: 1,
        tieneKilosRemitidos: 1,
        sincronizado: 0, // Inicialmente no sincronizado
        fechaSincronizacion: null, // Sin fecha de sincronización
      );

      // Guardar localmente
      final localSuccess = await provider.saveMaterialPesca(_formData);

      if (!localSuccess) {
        throw Exception('Error al guardar localmente');
      }

      // Intentar sincronizar con el API
      bool syncSuccess = false;
      try {
        syncSuccess = await _synchronizeWithApi(authProvider.token!, _formData);
      } catch (e) {
        print('Error en sincronización: $e');
        syncSuccess = false;
      }

      // Actualizar el estado según el resultado de la sincronización
      _formData = _formData.copyWith(
        sincronizado: syncSuccess ? 1 : 0,
        fechaSincronizacion: syncSuccess ? DateTime.now() : null,
      );

      // Guardar el estado actualizado
      await provider.saveMaterialPesca(_formData);

      if (!mounted) return;

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
            syncSuccess
                ? 'Material guardado y sincronizado correctamente'
                : 'Material guardado localmente (sin sincronización)',
          ),
          backgroundColor: syncSuccess ? Colors.green : Colors.orange,
        ),
      );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _formFields.isSaving = false);
    }
  }

  Future<bool> _synchronizeWithApi(String token, MaterialPesca data) async {
    try {
      final provider = Provider.of<MaterialPescaProvider>(
        context,
        listen: false,
      );
      return await provider.sincronizarMaterialPescaIndividual(token, data);
    } catch (e) {
      print('Error en sincronización individual: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _formData.lote == 0
              ? 'Nuevo Material'
              : 'Editar Lote ${_formData.lote}',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _formFields.isSaving ? null : _saveForm,
            tooltip: 'Guardar',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGuideInfoCard(dateFormat),
              const SizedBox(height: 24),
              _buildMaterialDataSection(),
              const SizedBox(height: 24),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideInfoCard(DateFormat dateFormat) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'INFORMACIÓN DE LA GUÍA',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _FormInfoRow(label: 'Guía:', value: _formData.nroGuia),
            _FormInfoRow(label: 'Programa:', value: _formData.nroPesca),
            _FormInfoRow(
              label: 'Camaronera:',
              value: _formData.camaronera.trim(),
            ),
            _FormInfoRow(label: 'Piscina:', value: _formData.piscina.trim()),
            _FormInfoRow(
              label: 'Fecha:',
              value: dateFormat.format(_formData.fechaGuia),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DATOS DEL MATERIAL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.blue,
          ),
        ),
        const Divider(),
        const SizedBox(height: 16),
        _formFields.buildLoteField(_formData.lote.toString()),
        _formFields.buildCicloField(
          value: _formData.ciclo,
          onChanged: (value) => setState(() {
            _formData = _formData.copyWith(ciclo: value);
          }),
        ),
        _formFields.buildAnioSiembraField(
          initialValue: _formData.anioSiembra?.toString(),
          onSaved: (value) => _formData = _formData.copyWith(
            anioSiembra: int.tryParse(value ?? ''),
          ),
        ),
        _formFields.buildIngresoCompraField(
          value: _formData.ingresoCompra,
          onChanged: (value) => setState(() {
            _formData = _formData.copyWith(ingresoCompra: value);
          }),
        ),
        _formFields.buildTipoMaterialField(
          value: _formData.tipoMaterial,
          onChanged: (value) => setState(() {
            _formData = _formData.copyWith(tipoMaterial: value);
          }),
        ),
        _formFields.buildCantidadMaterialField(
          initialValue: _formData.cantidadMaterial?.toString(),
          onSaved: (value) => _formData = _formData.copyWith(
            cantidadMaterial: int.tryParse(value ?? ''),
          ),
        ),
        _formFields.buildUnidadMedidaField(
          value: _formData.unidadMedida,
          onChanged: (value) => setState(() {
            _formData = _formData.copyWith(unidadMedida: value);
          }),
        ),
        _formFields.buildCantidadRemitidaField(
          initialValue: _formData.cantidadRemitida?.toString(),
          onSaved: (value) => _formData = _formData.copyWith(
            cantidadRemitida: double.tryParse(value ?? ''),
          ),
        ),
        _formFields.buildGramajeField(
          initialValue: _formData.gramaje?.toString(),
          onSaved: (value) => _formData = _formData.copyWith(
            gramaje: double.tryParse(value ?? ''),
          ),
        ),
        _formFields.buildProcesoField(
          value: _formData.proceso,
          onChanged: (value) => setState(() {
            _formData = _formData.copyWith(proceso: value);
          }),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.blue.shade700,
        ),
        onPressed: _formFields.isSaving ? null : _saveForm,
        child: _formFields.isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'GUARDAR MATERIAL',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
      ),
    );
  }
}

class _FormInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _FormInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
