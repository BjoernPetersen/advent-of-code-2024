import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:glob/glob.dart';

final class Supertypes {
  final InterfaceType intPart;
  final InterfaceType stringPart;

  Supertypes({
    required this.intPart,
    required this.stringPart,
  });
}

final class DayBuilder implements Builder {
  final BuilderOptions options;

  const DayBuilder(this.options);

  @override
  final Map<String, List<String>> buildExtensions = const {
    '.placeholder': ['.g.dart']
  };

  Future<Supertypes> _loadSupertypes(Resolver resolver) async {
    final lib = await resolver.libraryFor(
      AssetId.resolve(Uri.parse('package:aoc_core/aoc_core.dart')),
    );
    final namespace = lib.exportNamespace;
    return Supertypes(
      intPart: (namespace.get('IntPart')! as ClassElement).thisType,
      stringPart: (namespace.get('StringPart') as ClassElement).thisType,
    );
  }

  Future<PartDeclaration?> _tryLoadPart(
    Element element,
    Supertypes supertypes,
  ) async {
    if (element is! ClassElement) {
      return null;
    }

    if (!element.isPublic || element.isAbstract) {
      return null;
    }

    final supertype = element.supertype;

    if (supertype == null) {
      return null;
    }

    final bool isStringInput;
    if (supertype.element == supertypes.intPart.element) {
      isStringInput = false;
    } else if (supertype.element == supertypes.stringPart.element) {
      isStringInput = true;
    } else {
      return null;
    }

    final className = element.name;

    final partNumber = switch (className) {
      'PartOne' => 1,
      'PartTwo' => 2,
      _ => null,
    };

    if (partNumber == null) {
      print('Could not autodetect part number of class $element');
      return null;
    }

    return PartDeclaration(
      element: element,
      className: className,
      isStringInput: isStringInput,
      partNumber: partNumber,
    );
  }

  Future<List<PartDeclaration>> _tryLoadParts({
    required Supertypes supertypes,
    required LibraryElement library,
  }) async {
    final result = <PartDeclaration>[];

    for (final element in library.topLevelElements) {
      final partDeclaration = await _tryLoadPart(element, supertypes);
      if (partDeclaration != null) {
        result.add(partDeclaration);
      }
    }

    return result;
  }

  String _createContents(
    String libraryName,
    List<DayDeclaration> dayDeclarations,
  ) {
    final buffer = StringBuffer();

    // imports
    buffer.writeln("import 'package:aoc_core/aoc_core.dart';");

    for (final day in dayDeclarations) {
      final asset = day.assetId;
      buffer.write("import 'package:");
      buffer.write(asset.package);
      buffer.write('/');

      final pathSegments = asset.pathSegments.sublist(1);
      for (final (index, pathSegment) in pathSegments.indexed) {
        buffer.write(pathSegment);
        if (index != pathSegments.length - 1) {
          buffer.write('/');
        }
      }

      buffer.write("' as day_");
      buffer.write(day.day);
      buffer.writeln(';');
    }

    buffer.writeln();

    // availableDays constant
    buffer.write('const availableDays = <int>[');
    for (final day in dayDeclarations) {
      buffer.write(day.day);
      buffer.write(',');
    }
    buffer.writeln('];');
    buffer.writeln();

    // getDay implementation
    buffer.writeln('Day<Part, Part> getDay(int day) {');
    buffer.writeln('return switch (day) {');
    for (final day in dayDeclarations) {
      buffer.write(day.day);
      buffer.write(' => Day(');
      for (final (index, part) in day.parts.indexed) {
        buffer.write('day_');
        buffer.write(day.day);
        buffer.write('.');
        buffer.write(part.className);
        buffer.write('()');
        if (index != day.parts.length - 1) {
          buffer.write(',');
        }
      }
      buffer.writeln('),');
    }
    buffer.writeln(
        "final i => throw ArgumentError.value(day, 'day', 'day \$i not implemented'),");
    buffer.writeln('};');
    buffer.writeln('}');

    final formatter = DartFormatter();
    return formatter.format(buffer.toString());
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final supertypes = await _loadSupertypes(buildStep.resolver);
    final dayDeclarations = <DayDeclaration>[];

    final pathSegments = buildStep.inputId.pathSegments;
    final directory =
        pathSegments.sublist(0, pathSegments.length - 1).join('/');
    await for (final dayAsset in buildStep.findAssets(Glob(
      '$directory/days/day_*.dart',
    ))) {
      final LibraryElement library;
      try {
        library = await buildStep.resolver.libraryFor(dayAsset);
      } on SyntaxErrorInAssetException {
        print('Found syntax error in asset $dayAsset');
        continue;
      } on NonLibraryAssetException {
        continue;
      }

      final dayString =
          dayAsset.pathSegments.last.split('.')[0].split('_').last;
      final day = int.tryParse(dayString);
      if (day == null) {
        continue;
      }

      final partDeclarations = await _tryLoadParts(
        supertypes: supertypes,
        library: library,
      );

      if (partDeclarations.isNotEmpty) {
        dayDeclarations.add(DayDeclaration(
          assetId: dayAsset,
          day: day,
          parts: partDeclarations,
        ));
      }
    }

    dayDeclarations.sort((a, b) => a.day.compareTo(b.day));

    final inputLib = await buildStep.inputLibrary;
    final target = buildStep.inputId.changeExtension('.g.dart');
    unawaited(buildStep.writeAsString(
      target,
      _createContents(
        inputLib.source.shortName,
        dayDeclarations,
      ),
    ));
  }
}

final class DayDeclaration {
  final int day;
  final AssetId assetId;
  final List<PartDeclaration> parts;

  DayDeclaration._({
    required this.day,
    required this.assetId,
    required this.parts,
  });

  factory DayDeclaration({
    required int day,
    required List<PartDeclaration> parts,
    required AssetId assetId,
  }) {
    if (parts.isEmpty || parts.length > 2) {
      throw ArgumentError.value(parts, 'parts', 'must have >0 and <3 elements');
    }

    if (parts.map((e) => e.partNumber).toSet().length != parts.length) {
      throw ArgumentError.value(parts, 'parts', 'partNumbers must be unique');
    }

    if (parts.length == 1 && parts[0].partNumber == 2) {
      throw ArgumentError.value(
        parts,
        'parts',
        'part one must be implemented first',
      );
    }

    return DayDeclaration._(
      day: day,
      parts: parts,
      assetId: assetId,
    );
  }
}

final class PartDeclaration {
  final ClassElement element;
  final String className;
  final bool isStringInput;
  final int partNumber;

  PartDeclaration({
    required this.element,
    required this.className,
    required this.isStringInput,
    required this.partNumber,
  });
}
