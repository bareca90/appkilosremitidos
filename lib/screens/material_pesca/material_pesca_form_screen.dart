import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appkilosremitidos/core/providers/material_pesca_provider.dart';
import 'package:appkilosremitidos/models/material_pesca.dart';
import 'package:intl/intl.dart';

class MaterialPescaFormScreen extends StatefulWidget {
  final MaterialPesca data;

  const MaterialPescaFormScreen({super.key, required this.data});

  @override
  // ignore: library_private_types_in_public_api
  _MaterialPescaFormScreenState createState() =>
      _MaterialPescaFormScreenState();
}

class _MaterialPescaFormScreenState extends State<MaterialPescaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late MaterialPesca _formData;
  final List<String> _cicloOptions = ['A', 'B', 'C', 'D', 'E', 'F'];
  final List<String> _ingresoCompraOptions = ['S', 'N'];
  final List<String> _tipoMaterialOptions = ['Bin', 'Gvts'];
  final List<String> _unidadMedidaOptions = ['KG', 'LBS'];
  final List<String> _procesoOptions = ['CC', 'SC', 'CL'];

  @override
  void initState() {
    super.initState();
    _formData = widget.data;
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final provider = Provider.of<MaterialPescaProvider>(
          context,
          listen: false,
        );

        // Marcar como registro completo
        _formData = _formData.copyWith(tieneRegistro: 1);

        final success = await provider.saveMaterialPesca(_formData);

        if (success) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Material guardado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          // ignore: use_build_context_synchronously
          Navigator.pop(context, true); // Devuelve true indicando éxito
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al guardar el material'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar el material : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          _formData.lote == null
              ? 'Nuevo Material'
              : 'Editar Material Lote ${_formData.lote}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
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
              // Información de la guía
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Guía:', _formData.nroGuia),
                      _buildInfoRow('Programa:', _formData.nroPesca),
                      _buildInfoRow('Camaronera:', _formData.camaronera.trim()),
                      _buildInfoRow('Piscina:', _formData.piscina.trim()),
                      _buildInfoRow(
                        'Fecha:',
                        dateFormat.format(_formData.fechaGuia),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
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

              // Lote (solo lectura si está editando)
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Lote',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                initialValue: _formData.lote?.toString(),
                readOnly: true,
              ),
              const SizedBox(height: 16),

              // Ciclo
              _buildDropdownFormField(
                label: 'Ciclo',
                value: _formData.ciclo,
                items: _cicloOptions,
                onChanged: (value) {
                  setState(() {
                    _formData = _formData.copyWith(ciclo: value);
                  });
                },
              ),

              // Año Siembra
              _buildTextFormField(
                label: 'Año Siembra',
                initialValue: _formData.anioSiembra?.toString(),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  if (value != null && value.isNotEmpty) {
                    _formData = _formData.copyWith(
                      anioSiembra: int.tryParse(value),
                    );
                  }
                },
              ),

              // Ingreso/Compra
              _buildDropdownFormField(
                label: 'Ingreso/Compra',
                value: _formData.ingresoCompra,
                items: _ingresoCompraOptions,
                onChanged: (value) {
                  setState(() {
                    _formData = _formData.copyWith(ingresoCompra: value);
                  });
                },
                itemBuilder: (value) {
                  return Text(value == 'S' ? 'Si' : 'No');
                },
              ),

              // Tipo Material (requerido)
              _buildDropdownFormField(
                label: 'Tipo Material*',
                value: _formData.tipoMaterial,
                items: _tipoMaterialOptions,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleccione el tipo de material';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _formData = _formData.copyWith(tipoMaterial: value);
                  });
                },
              ),

              // Cantidad Material (requerido)
              _buildTextFormField(
                label: 'Cantidad Material*',
                initialValue: _formData.cantidadMaterial?.toString(),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la cantidad';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value != null && value.isNotEmpty) {
                    _formData = _formData.copyWith(
                      cantidadMaterial: int.tryParse(value),
                    );
                  }
                },
              ),

              // Unidad Medida (requerido)
              _buildDropdownFormField(
                label: 'Unidad Medida*',
                value: _formData.unidadMedida,
                items: _unidadMedidaOptions,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleccione la unidad';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _formData = _formData.copyWith(unidadMedida: value);
                  });
                },
              ),

              // Cantidad Remitida (requerido)
              _buildTextFormField(
                label: 'Cantidad Remitida (kg)*',
                initialValue: _formData.cantidadRemitida?.toString(),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la cantidad';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
                onSaved: (value) {
                  if (value != null && value.isNotEmpty) {
                    _formData = _formData.copyWith(
                      cantidadRemitida: double.tryParse(value),
                    );
                  }
                },
              ),

              // Gramaje
              _buildTextFormField(
                label: 'Gramaje (g)',
                initialValue: _formData.gramaje?.toString(),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  if (value != null && value.isNotEmpty) {
                    _formData = _formData.copyWith(
                      gramaje: double.tryParse(value),
                    );
                  }
                },
              ),

              // Proceso
              _buildDropdownFormField(
                label: 'Proceso',
                value: _formData.proceso,
                items: _procesoOptions,
                onChanged: (value) {
                  setState(() {
                    _formData = _formData.copyWith(proceso: value);
                  });
                },
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _saveForm,
                  child: const Text(
                    'GUARDAR MATERIAL',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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

  Widget _buildDropdownFormField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
    Widget Function(String)? itemBuilder,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        value: value,
        items: items.map((value) {
          return DropdownMenuItem<String>(
            value: value,
            child: itemBuilder != null ? itemBuilder(value) : Text(value),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    String? initialValue,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Function(String?)? onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        initialValue: initialValue,
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}
