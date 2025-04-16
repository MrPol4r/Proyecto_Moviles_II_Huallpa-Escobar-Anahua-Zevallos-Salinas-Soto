import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Item {
  final String nombre;
  final String tipo;
  final double precio;
  final DateTime fecha;

  Item({required this.nombre, required this.tipo, required this.precio, required this.fecha});
}

class FiltrosCaer extends StatefulWidget {
  @override
  _FiltrosCaerState createState() => _FiltrosCaerState();
}

class _FiltrosCaerState extends State<FiltrosCaer> {
  final List<Item> items = [
    Item(nombre: 'Producto A', tipo: 'Electrónica', precio: 100.0, fecha: DateTime(2025, 4, 1)),
    Item(nombre: 'Producto B', tipo: 'Ropa', precio: 50.0, fecha: DateTime(2025, 4, 5)),
    Item(nombre: 'Producto C', tipo: 'Electrónica', precio: 300.0, fecha: DateTime(2025, 4, 10)),
    Item(nombre: 'Producto D', tipo: 'Libros', precio: 25.0, fecha: DateTime(2025, 4, 15)),
  ];

  String? tipoSeleccionado;
  RangeValues precioRango = RangeValues(0, 500);
  DateTime? fechaDesde;
  DateTime? fechaHasta;

  List<Item> get itemsFiltrados {
    return items.where((item) {
      final coincideTipo = tipoSeleccionado == null || item.tipo == tipoSeleccionado;
      final coincidePrecio = item.precio >= precioRango.start && item.precio <= precioRango.end;
      final coincideFecha = (fechaDesde == null || item.fecha.isAfter(fechaDesde!.subtract(Duration(days: 1)))) &&
                            (fechaHasta == null || item.fecha.isBefore(fechaHasta!.add(Duration(days: 1))));
      return coincideTipo && coincidePrecio && coincideFecha;
    }).toList();
  }

  Future<void> seleccionarFecha({required bool esDesde}) async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
    );

    if (fechaSeleccionada != null) {
      setState(() {
        if (esDesde) {
          fechaDesde = fechaSeleccionada;
        } else {
          fechaHasta = fechaSeleccionada;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiposDisponibles = items.map((e) => e.tipo).toSet().toList();

    return Scaffold(
      appBar: AppBar(title: Text('Filtros de Búsqueda')),
      body: Column(
        children: [
          ExpansionTile(
            title: Text('Filtros'),
            children: [
              DropdownButton<String>(
                hint: Text('Tipo'),
                value: tipoSeleccionado,
                items: tiposDisponibles
                    .map((tipo) => DropdownMenu
