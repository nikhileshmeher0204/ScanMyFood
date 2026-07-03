import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:read_the_label/services/tools/tool_execution_client.dart';

class GetUserProfileClientFunction implements ClientFunction {
  final ToolExecutionClient toolClient;
  GetUserProfileClientFunction(this.toolClient);

  @override
  String get name => 'getUserProfile';

  @override
  String get description => 'Fetches the user\'s health profile including weight, height, BMI, dietary preferences, health conditions, and fitness goals.';

  @override
  Schema get argumentSchema => Schema.object(properties: {});

  @override
  ClientFunctionReturnType get returnType => ClientFunctionReturnType.object;

  @override
  Stream<Object?> execute(JsonMap args, ExecutionContext context) {
    return Stream.fromFuture(toolClient.execute(name, {}));
  }
}

class LogMealClientFunction implements ClientFunction {
  final ToolExecutionClient toolClient;
  LogMealClientFunction(this.toolClient);

  @override
  String get name => 'logMealViaDescription';

  @override
  String get description => 'Analyzes a natural language meal description to extract nutritional data and saves it.';

  @override
  Schema get argumentSchema => Schema.object(
        properties: {
          'description': Schema.string(
            description: 'Natural language description of the meal (e.g. "2 eggs and toast with butter")',
          ),
        },
      );

  @override
  ClientFunctionReturnType get returnType => ClientFunctionReturnType.object;

  @override
  Stream<Object?> execute(JsonMap args, ExecutionContext context) {
    final description = args['description'] as String? ?? '';
    return Stream.fromFuture(toolClient.execute(name, {'description': description}));
  }
}

class SaveScannedFoodIntakeClientFunction implements ClientFunction {
  final ToolExecutionClient toolClient;
  SaveScannedFoodIntakeClientFunction(this.toolClient);

  @override
  String get name => 'saveScannedFoodIntake';

  @override
  String get description => 'Saves the analyzed food details into the user\'s daily intake log.';

  @override
  Schema get argumentSchema => Schema.object(
        properties: {
          'food_analysis_response': Schema.object(properties: {}),
          'source_of_intake': Schema.string(),
          'created_at': Schema.string(),
        },
      );

  @override
  ClientFunctionReturnType get returnType => ClientFunctionReturnType.object;

  @override
  Stream<Object?> execute(JsonMap args, ExecutionContext context) {
    return Stream.fromFuture(toolClient.execute(name, args));
  }
}

class NutritionCatalog {
  static Catalog create(ToolExecutionClient toolClient) {
    final baseCatalog = BasicCatalogItems.asCatalog();
    return baseCatalog.copyWith(
      newFunctions: [
        GetUserProfileClientFunction(toolClient),
        LogMealClientFunction(toolClient),
        SaveScannedFoodIntakeClientFunction(toolClient),
      ],
    );
  }
}
