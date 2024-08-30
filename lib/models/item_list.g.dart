// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemListAdapter extends TypeAdapter<ItemList> {
  @override
  final int typeId = 1;

  @override
  ItemList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemList(
      title: fields[0] as String,
      items: (fields[1] as List?)?.cast<Item>(),
    );
  }

  @override
  void write(BinaryWriter writer, ItemList obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
