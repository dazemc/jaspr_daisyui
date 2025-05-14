import 'dart:convert';
import 'dart:io';

import 'package:build/build.dart';
import 'package:build_modules/build_modules.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

Builder buildStylesheet(BuilderOptions options) => TailwindBuilder(options);

class TailwindBuilder implements Builder {
  final BuilderOptions options;

  TailwindBuilder(this.options);

  @override
  Future<void> build(BuildStep buildStep) async {
    final scratchSpace = await buildStep.fetchResource(scratchSpaceResource);

    await scratchSpace.ensureAssets({buildStep.inputId}, buildStep);

    final outputId = buildStep.inputId.changeExtension('').changeExtension('.css');

    final packageFile = File('.dart_tool/package_config.json');
    final packageJson = jsonDecode(await packageFile.readAsString());

    final packageConfig = (packageJson['packages'] as List?)?.where((p) => p['name'] == 'jaspr_daisyui').firstOrNull;
    if (packageConfig == null) {
      print("Cannot find 'jaspr_daisyui' in package config.");
      return;
    }

    // DaisyUI
    final daisyPluginInput = AssetId(buildStep.inputId.package, 'web/daisyui.js');
    final hasDaisyPlugin = await buildStep.canRead(daisyPluginInput);
    final daisyThemeInput = AssetId(buildStep.inputId.package, 'web/daisyui-theme.js');
    final hasDaisyTheme = await buildStep.canRead(daisyThemeInput);

    if (hasDaisyPlugin) {
      await scratchSpace.ensureAssets({daisyPluginInput}, buildStep);
    }
    if (hasDaisyTheme) {
      await scratchSpace.ensureAssets({daisyThemeInput}, buildStep);
    }

    // in order to rebuild when source files change
    final assets = await buildStep.findAssets(Glob('{lib,web}/**.dart')).toList();
    await Future.wait(assets.map((a) => buildStep.canRead(a)));

    final configFile = File('tailwind.config.js');
    final hasCustomConfig = await configFile.exists();

    await Process.run(
      'tailwindcss',
      [
        '--input',
        scratchSpace.fileFor(buildStep.inputId).path,
        '--output',
        scratchSpace.fileFor(outputId).path.toPosix(),
        if (options.config.containsKey('tailwindcss')) options.config['tailwindcss'] as String,
        if (hasCustomConfig) ...[
          '--config',
          p.join(Directory.current.path, 'tailwind.config.js').toPosix(),
        ] else ...[
          '--content',
          p.join(Directory.current.path, '{lib,web}', '**', '*.dart').toPosix(true),
        ],
      ],
      runInShell: true,
    );

    await scratchSpace.copyOutput(outputId, buildStep);
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        'web/{{file}}.tw.css': ['web/{{file}}.css']
      };
}

extension POSIXPath on String {
  String toPosix([bool quoted = false]) {
    if (Platform.isWindows) {
      final result = replaceAll('\\', '/');
      return quoted ? "'$result'" : result;
    }
    return this;
  }
}
