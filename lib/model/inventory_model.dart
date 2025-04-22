class InventoryItem {
  String id;
  String nombre;
  String marca;
  String modelo;
  String numeroSerie;
  String estado;
  String photo;

  InventoryItem({
    required this.id,
    required this.nombre,
    required this.marca,
    required this.modelo,
    required this.numeroSerie,
    required this.estado,
    required this.photo,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'],
      nombre: json['nombre'],
      marca: json['marca'],
      modelo: json['modelo'],
      numeroSerie: json['numeroSerie'],
      estado: json['estado'],
      photo: json['photo'],
    );
  }
}
