import 'package:flutter/material.dart';

class MaterialPescaFormFields {
  bool isSaving = false;

  Widget buildLoteField(String initialValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: 'Lote',
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        initialValue: initialValue,
        readOnly: true,
      ),
    );
  }

  Widget buildCicloField({
    required String? value,
    required Function(String?) onChanged,
  }) {
    return _buildDropdownFormField(
      label: 'Ciclo',
      value: value,
      items: const ['A', 'B', 'C', 'D', 'E', 'F'],
      onChanged: onChanged,
    );
  }

  Widget buildAnioSiembraField({
    String? initialValue,
    required Function(String?) onSaved,
  }) {
    return _buildTextFormField(
      label: 'Año Siembra',
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingrese el año';
        if (int.tryParse(value) == null) return 'Año inválido';
        return null;
      },
      onSaved: onSaved,
    );
  }

  Widget buildIngresoCompraField({
    required String? value,
    required Function(String?) onChanged,
  }) {
    return _buildDropdownFormField(
      label: 'Ingreso/Compra',
      value: value,
      items: const ['S', 'N'],
      onChanged: onChanged,
      itemBuilder: (value) => Text(value == 'S' ? 'Sí' : 'No'),
    );
  }

  Widget buildTipoMaterialField({
    required String? value,
    required Function(String?) onChanged,
  }) {
    return _buildDropdownFormField(
      label: 'Tipo Material*',
      value: value,
      items: const ['Bin', 'Gvts'],
      validator: (value) => value == null ? 'Seleccione el tipo' : null,
      onChanged: onChanged,
    );
  }

  Widget buildCantidadMaterialField({
    String? initialValue,
    required Function(String?) onSaved,
  }) {
    return _buildTextFormField(
      label: 'Cantidad Material*',
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingrese la cantidad';
        if (int.tryParse(value) == null) return 'Número inválido';
        return null;
      },
      onSaved: onSaved,
    );
  }

  Widget buildUnidadMedidaField({
    required String? value,
    required Function(String?) onChanged,
  }) {
    return _buildDropdownFormField(
      label: 'Unidad Medida*',
      value: value,
      items: const ['KG', 'LBS'],
      validator: (value) => value == null ? 'Seleccione la unidad' : null,
      onChanged: onChanged,
    );
  }

  Widget buildCantidadRemitidaField({
    String? initialValue,
    required Function(String?) onSaved,
  }) {
    return _buildTextFormField(
      label: 'Cantidad Remitida (kg)*',
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Ingrese la cantidad';
        if (double.tryParse(value) == null) return 'Número inválido';
        return null;
      },
      onSaved: onSaved,
    );
  }

  Widget buildGramajeField({
    String? initialValue,
    required Function(String?) onSaved,
  }) {
    return _buildTextFormField(
      label: 'Gramaje (g)',
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      onSaved: onSaved,
    );
  }

  Widget buildProcesoField({
    required String? value,
    required Function(String?) onChanged,
  }) {
    return _buildDropdownFormField(
      label: 'Proceso',
      value: value,
      items: const ['CC', 'SC', 'CL'],
      onChanged: onChanged,
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
        items: items
            .map(
              (value) => DropdownMenuItem<String>(
                value: value,
                child: itemBuilder != null ? itemBuilder(value) : Text(value),
              ),
            )
            .toList(),
        onChanged: isSaving ? null : onChanged,
        validator: validator,
      ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    String? initialValue,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required Function(String?) onSaved,
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
        enabled: !isSaving,
      ),
    );
  }
}
