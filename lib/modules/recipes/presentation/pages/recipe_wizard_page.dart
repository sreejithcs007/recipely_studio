import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Services & DI
import '../../../../core/services/dialog_service.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../shared/widgets/badges/custom_badges.dart';
import '../../../../shared/widgets/buttons/custom_buttons.dart';
import '../../../../shared/widgets/forms/custom_form_fields.dart';
import '../../../../shared/widgets/chips/custom_chips.dart';

// Blocs & Entities
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../bloc/recipe_bloc.dart';
import '../../../categories/presentation/bloc/category_bloc.dart';
import '../../../tags/presentation/bloc/tag_bloc.dart';

class RecipeWizardPage extends StatefulWidget {
  final String? recipeId;

  const RecipeWizardPage({super.key, this.recipeId});

  @override
  State<RecipeWizardPage> createState() => _RecipeWizardPageState();
}

class _RecipeWizardPageState extends State<RecipeWizardPage> {
  int _currentStep = 1;
  bool _isInitLoading = false;
  Recipe? _existingRecipe;

  // Step 1 Controllers
  final _step1FormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _prepTimeController = TextEditingController(text: '15');
  final _cookTimeController = TextEditingController(text: '30');
  final _caloriesController = TextEditingController(text: '350');
  final _servingsController = TextEditingController(text: '4');
  final _costController = TextEditingController(text: '15.0');
  
  String _selectedCuisine = 'Italian';
  String _selectedDifficulty = 'Easy';
  int _selectedSpiceLevel = 0;

  // Step 3 Ingredient helper controllers
  final _ingNameController = TextEditingController();
  final _ingQtyController = TextEditingController();
  final _ingUnitController = TextEditingController();
  bool _ingOptional = false;
  int? _editingIngredientIndex;

  // Step 4 Step helper controller
  final _stepContentController = TextEditingController();
  int? _editingStepIndex;

  // Step 5 selected category & tag IDs
  List<String> _selectedCategoryIds = [];
  List<String> _selectedTagIds = [];

  // Step 6 Publish status toggle
  String _publishStatus = 'published';
  bool _isFeatured = false;
  bool _isTrending = false;

  @override
  void initState() {
    super.initState();
    // Load category and tag datasets
    context.read<CategoryBloc>().add(LoadCategories());
    context.read<TagBloc>().add(LoadTags());

    // Reset editor cubits for fresh edit
    context.read<IngredientCubit>().clear();
    context.read<InstructionCubit>().clear();
    context.read<RecipeImageCubit>().clearImage();

    if (widget.recipeId != null) {
      _loadExistingRecipe();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _caloriesController.dispose();
    _servingsController.dispose();
    _costController.dispose();
    _ingNameController.dispose();
    _ingQtyController.dispose();
    _ingUnitController.dispose();
    _stepContentController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingRecipe() async {
    setState(() => _isInitLoading = true);
    try {
      final repo = GetIt.I<RecipeRepository>();
      final recipe = await repo.getRecipeById(widget.recipeId!);
      setState(() {
        _existingRecipe = recipe;
        _titleController.text = recipe.title;
        _descController.text = recipe.description;
        _prepTimeController.text = '${recipe.prepTimeMinutes}';
        _cookTimeController.text = '${recipe.cookTimeMinutes}';
        _caloriesController.text = '${recipe.caloriesInt}';
        _servingsController.text = '${recipe.servingsInt}';
        _costController.text = '${recipe.estimatedCost}';
        _selectedCuisine = recipe.cuisine ?? 'Italian';
        _selectedDifficulty = recipe.difficulty;
        _selectedSpiceLevel = recipe.spiceLevel;
        _publishStatus = recipe.status;
        _isFeatured = recipe.isFeatured;
        _isTrending = recipe.isTrending;

        // Pre-select category and tag junctions
        // Note: For existing recipes, our data source joined and mapped junction names.
        // We will preselect matching categories by name/ID.
        // Wait, for categories, categories list will load soon. We can map them.
        _selectedCategoryIds = List<String>.from(recipe.categories);
        _selectedTagIds = List<String>.from(recipe.tags);
      });

      // Populate Cubits
      if (mounted) {
        context.read<RecipeImageCubit>().setImageUrl(recipe.imageUrl);
        context.read<IngredientCubit>().setIngredients(recipe.ingredients);
        context.read<InstructionCubit>().setSteps(recipe.steps);
      }
    } catch (e) {
      GetIt.I<SnackbarService>().showError('Error loading recipe details: $e');
    } finally {
      setState(() => _isInitLoading = false);
    }
  }

  void _onNext() {
    if (_currentStep == 1) {
      if (!_step1FormKey.currentState!.validate()) return;
    }
    if (_currentStep == 2) {
      final imageUrl = context.read<RecipeImageCubit>().state.imageUrl;
      if (imageUrl.isEmpty) {
        GetIt.I<SnackbarService>().showWarning('Please upload or provide a recipe cover image.');
        return;
      }
    }
    if (_currentStep == 3) {
      final ingredients = context.read<IngredientCubit>().state;
      if (ingredients.isEmpty) {
        GetIt.I<SnackbarService>().showWarning('Please add at least one ingredient.');
        return;
      }
    }
    if (_currentStep == 4) {
      final steps = context.read<InstructionCubit>().state;
      if (steps.isEmpty) {
        GetIt.I<SnackbarService>().showWarning('Please add at least one step of instruction.');
        return;
      }
    }

    if (_currentStep < 6) {
      setState(() {
        _currentStep += 1;
      });
    }
  }

  void _onBack() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  void _onSaveAndSubmit() {
    final imageState = context.read<RecipeImageCubit>().state;
    final ingredients = context.read<IngredientCubit>().state;
    final steps = context.read<InstructionCubit>().state;

    // Convert inputs safely
    final prepMins = int.tryParse(_prepTimeController.text) ?? 15;
    final cookMins = int.tryParse(_cookTimeController.text) ?? 30;
    final calories = int.tryParse(_caloriesController.text) ?? 350;
    final servings = int.tryParse(_servingsController.text) ?? 4;
    final cost = double.tryParse(_costController.text) ?? 15.0;

    final recipePayload = Recipe(
      id: _existingRecipe?.id ?? '',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      rating: _existingRecipe?.rating ?? 4.5,
      reviewsCount: _existingRecipe?.reviewsCount ?? 0,
      prepTime: '$prepMins mins',
      cookTime: '$cookMins mins',
      totalTime: '${prepMins + cookMins} mins',
      calories: '$calories kcal',
      servings: '$servings servings',
      prepTimeMinutes: prepMins,
      cookTimeMinutes: cookMins,
      totalTimeMinutes: prepMins + cookMins,
      caloriesInt: calories,
      servingsInt: servings,
      cuisine: _selectedCuisine,
      difficulty: _selectedDifficulty,
      spiceLevel: _selectedSpiceLevel,
      estimatedCost: cost,
      status: _publishStatus,
      isFeatured: _isFeatured,
      isTrending: _isTrending,
      isRecommended: _existingRecipe?.isRecommended ?? false,
      imageUrl: imageState.imageUrl,
      createdAt: _existingRecipe?.createdAt ?? DateTime.now(),
      ingredients: ingredients,
      steps: steps,
    );

    // Filter junction lists to extract matching raw IDs from selections
    final categoriesState = context.read<CategoryBloc>().state;
    List<String> rawCategoryIds = [];
    if (categoriesState is CategoryLoaded) {
      rawCategoryIds = categoriesState.categories
          .where((c) => _selectedCategoryIds.contains(c.name) || _selectedCategoryIds.contains(c.id))
          .map((c) => c.id)
          .toList();
    }

    final tagsState = context.read<TagBloc>().state;
    List<String> rawTagIds = [];
    if (tagsState is TagLoaded) {
      rawTagIds = tagsState.tags
          .where((t) => _selectedTagIds.contains(t.name) || _selectedTagIds.contains(t.id))
          .map((t) => t.id)
          .toList();
    }

    context.read<RecipeEditorBloc>().add(
          SaveRecipeRequested(
            recipe: recipePayload,
            categoryIds: rawCategoryIds,
            tagIds: rawTagIds,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF18181B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0);
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return BlocListener<RecipeEditorBloc, RecipeEditorState>(
      listener: (context, state) {
        if (state is RecipeEditorSaveSuccess) {
          GetIt.I<SnackbarService>().showSuccess('Recipe saved successfully!');
          context.go('/recipes');
        } else if (state is RecipeEditorSaveFailure) {
          GetIt.I<SnackbarService>().showError('Save failed: ${state.error}');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/recipes'),
          ),
          title: Text(widget.recipeId == null ? 'Create Recipe Wizard' : 'Edit Recipe Wizard'),
        ),
        body: Column(
          children: [
            // Step Indicators Progress Bar
            _buildProgressBar(),
            
            // Active Step View
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.all(32),
                    child: _buildStepContent(titleColor, isDark),
                  ),
                ),
              ),
            ),

            // Step Navigation Footer
            _buildNavigationFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(6, (index) {
          final stepNum = index + 1;
          final isActive = _currentStep == stepNum;
          final isCompleted = _currentStep > stepNum;

          return Expanded(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isActive
                      ? primaryColor
                      : (isCompleted ? Colors.green : Colors.grey[350]),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : Text(
                          '$stepNum',
                          style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(width: 8),
                if (index < 5)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? Colors.green : Colors.grey[300],
                      margin: const EdgeInsets.only(right: 8),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(Color titleColor, bool isDark) {
    switch (_currentStep) {
      case 1:
        return _buildStep1(titleColor);
      case 2:
        return _buildStep2(titleColor);
      case 3:
        return _buildStep3(titleColor, isDark);
      case 4:
        return _buildStep4(titleColor, isDark);
      case 5:
        return _buildStep5(titleColor);
      case 6:
        return _buildStep6(titleColor, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1(Color titleColor) {
    final cuisinesList = ['Italian', 'Mexican', 'Indian', 'Japanese', 'Chinese', 'American', 'French', 'Mediterranean'];
    final difficultiesList = ['Easy', 'Medium', 'Hard'];

    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step 1: Basic Recipe Details',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Recipe Title',
            hintText: 'e.g. Classic Lasagna Bolognese',
            controller: _titleController,
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter recipe title' : null,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            label: 'Description',
            hintText: 'Provide a brief and engaging introduction to this recipe...',
            controller: _descController,
            maxLines: 3,
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter recipe description' : null,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Prep Time (minutes)',
                  controller: _prepTimeController,
                  keyboardType: TextInputType.number,
                  validator: (val) => int.tryParse(val ?? '') == null ? 'Enter minutes' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'Cook Time (minutes)',
                  controller: _cookTimeController,
                  keyboardType: TextInputType.number,
                  validator: (val) => int.tryParse(val ?? '') == null ? 'Enter minutes' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Calories (kcal)',
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  validator: (val) => int.tryParse(val ?? '') == null ? 'Enter kcal' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'Servings',
                  controller: _servingsController,
                  keyboardType: TextInputType.number,
                  validator: (val) => int.tryParse(val ?? '') == null ? 'Enter servings count' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'Est. Cost (\$)',
                  controller: _costController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (val) => double.tryParse(val ?? '') == null ? 'Enter cost' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomDropdown<String>(
                  label: 'Cuisine',
                  value: _selectedCuisine,
                  items: cuisinesList.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCuisine = val);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomDropdown<String>(
                  label: 'Difficulty',
                  value: _selectedDifficulty,
                  items: difficultiesList.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDifficulty = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Spice Level (0: None, 3: Very Spicy)',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Slider(
            value: _selectedSpiceLevel.toDouble(),
            min: 0,
            max: 3,
            divisions: 3,
            label: 'Level $_selectedSpiceLevel',
            activeColor: Theme.of(context).primaryColor,
            onChanged: (val) {
              setState(() => _selectedSpiceLevel = val.toInt());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(Color titleColor) {
    return BlocBuilder<RecipeImageCubit, RecipeImageState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 2: Cover Photo Media',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
            ),
            const SizedBox(height: 24),
            // Custom Upload Dropzone visual
            InkWell(
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  allowMultiple: false,
                );
                if (result != null && result.files.first.bytes != null && mounted) {
                  final file = result.files.first;
                  context.read<RecipeImageCubit>().uploadImage(file.bytes!, file.name);
                }
              },
              child: Container(
                width: double.infinity,
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.05),
                  border: Border.all(color: Colors.grey[400]!, width: 2, style: BorderStyle.none),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: state.isUploading
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text('Uploading Cover Image...', style: GoogleFonts.inter()),
                        ],
                      )
                    : state.imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: state.imageUrl,
                                  width: double.infinity,
                                  height: 240,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: FloatingActionButton.small(
                                    backgroundColor: Colors.white,
                                    onPressed: () => context.read<RecipeImageCubit>().clearImage(),
                                    child: const Icon(Icons.delete, color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey),
                              const SizedBox(height: 12),
                              Text(
                                'Click to Upload Recipe Cover Photo',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 4),
                              Text('PNG, JPG, or WEBP formats supported.', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 20),
            // Text Input as direct fallback
            CustomTextField(
              label: 'Or enter Cover Image Public URL directly',
              hintText: 'https://images.unsplash.com/...',
              controller: TextEditingController(text: state.imageUrl),
              onChanged: (val) {
                if (val.trim().isNotEmpty) {
                  context.read<RecipeImageCubit>().setImageUrl(val.trim());
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStep3(Color titleColor, bool isDark) {
    return BlocBuilder<IngredientCubit, List<Ingredient>>(
      builder: (context, ingredients) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 3: Ingredients Checklist',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
            ),
            const SizedBox(height: 24),
            // Ingredient addition inline form
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    label: 'Ingredient Name',
                    hintText: 'e.g. Grated Parmesan Cheese',
                    controller: _ingNameController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: CustomTextField(
                    label: 'Qty',
                    hintText: 'e.g. 2, 1/2',
                    controller: _ingQtyController,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: CustomTextField(
                    label: 'Unit',
                    hintText: 'e.g. cups, g, oz',
                    controller: _ingUnitController,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  children: [
                    Text('Optional', style: GoogleFonts.inter(fontSize: 12)),
                    Checkbox(
                      value: _ingOptional,
                      onChanged: (val) => setState(() => _ingOptional = val ?? false),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                PrimaryButton(
                  label: _editingIngredientIndex != null ? 'Save' : 'Add',
                  onPressed: () {
                    final name = _ingNameController.text.trim();
                    final qty = _ingQtyController.text.trim();
                    if (name.isNotEmpty && qty.isNotEmpty) {
                      final ing = Ingredient(
                        name: name,
                        quantity: qty,
                        unit: _ingUnitController.text.trim().isEmpty ? null : _ingUnitController.text.trim(),
                        isOptional: _ingOptional,
                      );
                      if (_editingIngredientIndex != null) {
                        context.read<IngredientCubit>().editIngredient(_editingIngredientIndex!, ing);
                      } else {
                        context.read<IngredientCubit>().addIngredient(ing);
                      }
                      _ingNameController.clear();
                      _ingQtyController.clear();
                      _ingUnitController.clear();
                      setState(() {
                        _editingIngredientIndex = null;
                        _ingOptional = false;
                      });
                    }
                  },
                ),
                if (_editingIngredientIndex != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      _ingNameController.clear();
                      _ingQtyController.clear();
                      _ingUnitController.clear();
                      setState(() {
                        _editingIngredientIndex = null;
                        _ingOptional = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            // Listed ingredients
            if (ingredients.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'No ingredients added. Fill fields above to add ingredients.',
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: ingredients.length,
                  separatorBuilder: (c, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final ing = ingredients[index];
                    return ListTile(
                      title: Text('${ing.quantity} ${ing.unit ?? ''} ${ing.name}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (ing.isOptional) StatusBadge(status: 'draft'),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: Colors.blue, size: 20),
                            onPressed: () {
                              setState(() {
                                _editingIngredientIndex = index;
                                _ingNameController.text = ing.name;
                                _ingQtyController.text = ing.quantity;
                                _ingUnitController.text = ing.unit ?? '';
                                _ingOptional = ing.isOptional;
                              });
                            },
                            tooltip: 'Edit Ingredient',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                            onPressed: () {
                              if (_editingIngredientIndex == index) {
                                setState(() {
                                  _editingIngredientIndex = null;
                                  _ingNameController.clear();
                                  _ingQtyController.clear();
                                  _ingUnitController.clear();
                                  _ingOptional = false;
                                });
                              }
                              context.read<IngredientCubit>().removeIngredient(index);
                            },
                            tooltip: 'Delete Ingredient',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStep4(Color titleColor, bool isDark) {
    return BlocBuilder<InstructionCubit, List<StepItem>>(
      builder: (context, steps) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 4: Instruction Steps',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
            ),
            const SizedBox(height: 24),
            // Instruction step builder form
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: CustomTextField(
                    label: _editingStepIndex != null
                        ? 'Edit content for Step #${_editingStepIndex! + 1}'
                        : 'Instruction content for Step #${steps.length + 1}',
                    hintText: 'Describe preparation procedures clearly here...',
                    controller: _stepContentController,
                  ),
                ),
                const SizedBox(width: 12),
                PrimaryButton(
                  label: _editingStepIndex != null ? 'Save Step' : 'Add Step',
                  onPressed: () {
                    final content = _stepContentController.text.trim();
                    if (content.isNotEmpty) {
                      if (_editingStepIndex != null) {
                        context.read<InstructionCubit>().editStep(_editingStepIndex!, content);
                      } else {
                        context.read<InstructionCubit>().addStep(content);
                      }
                      _stepContentController.clear();
                      setState(() {
                        _editingStepIndex = null;
                      });
                    }
                  },
                ),
                if (_editingStepIndex != null) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () {
                      _stepContentController.clear();
                      setState(() {
                        _editingStepIndex = null;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            // Listed steps
            if (steps.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'No steps added yet. Add instruction steps to guide users.',
                    style: GoogleFonts.inter(color: Colors.grey),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: steps.length,
                  separatorBuilder: (c, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Text(
                          '${step.stepNumber}',
                          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(step.content),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: Colors.blue, size: 20),
                            onPressed: () {
                              setState(() {
                                _editingStepIndex = index;
                                _stepContentController.text = step.content;
                              });
                            },
                            tooltip: 'Edit Step',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                            onPressed: () {
                              if (_editingStepIndex == index) {
                                setState(() {
                                  _editingStepIndex = null;
                                  _stepContentController.clear();
                                });
                              }
                              context.read<InstructionCubit>().removeStep(index);
                            },
                            tooltip: 'Delete Step',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStep5(Color titleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 5: Category & Tag Junctions',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
        ),
        const SizedBox(height: 24),
        Text(
          'Map Recipe Categories',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        // Load categories
        BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const CircularProgressIndicator();
            } else if (state is CategoryLoaded) {
              return MultiSelectChips<String>(
                items: state.categories.map((c) => c.name).toList(),
                selectedItems: _selectedCategoryIds,
                labelBuilder: (name) => name,
                onSelectionChanged: (val) {
                  setState(() {
                    _selectedCategoryIds = val;
                  });
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 32),
        Text(
          'Map Recipe Tags',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        // Load tags
        BlocBuilder<TagBloc, TagState>(
          builder: (context, state) {
            if (state is TagLoading) {
              return const CircularProgressIndicator();
            } else if (state is TagLoaded) {
              return MultiSelectChips<String>(
                items: state.tags.map((t) => t.name).toList(),
                selectedItems: _selectedTagIds,
                labelBuilder: (name) => name,
                onSelectionChanged: (val) {
                  setState(() {
                    _selectedTagIds = val;
                  });
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildStep6(Color titleColor, bool isDark) {
    final imageState = context.read<RecipeImageCubit>().state;
    final ingredients = context.read<IngredientCubit>().state;
    final steps = context.read<InstructionCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 6: Review & Finalize Publish',
          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: titleColor),
        ),
        const SizedBox(height: 24),
        // Preview Header
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: imageState.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageState.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.restaurant, size: 28),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titleController.text.isNotEmpty ? _titleController.text : 'Untitled Recipe',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_selectedCuisine} • ${_selectedDifficulty} difficulty • ${_prepTimeController.text}m Prep / ${_cookTimeController.text}m Cook',
                    style: GoogleFonts.inter(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 40),
        // Summary statistics
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatSummary('Ingredients', '${ingredients.length} items'),
            _buildStatSummary('Instructions', '${steps.length} steps'),
            _buildStatSummary('Est. Cost', '\$${_costController.text}'),
            _buildStatSummary('Calories', '${_caloriesController.text} kcal'),
          ],
        ),
        const Divider(height: 40),
        // Publish status
        Text(
          'Publishing Configuration Status',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Radio<String>(
              value: 'published',
              groupValue: _publishStatus,
              onChanged: (val) {
                if (val != null) setState(() => _publishStatus = val);
              },
            ),
            Text('PUBLISH IMMEDIATELY', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
            const SizedBox(width: 32),
            Radio<String>(
              value: 'draft',
              groupValue: _publishStatus,
              onChanged: (val) {
                if (val != null) setState(() => _publishStatus = val);
              },
            ),
            Text('SAVE AS DRAFT', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          ],
        ),
        const Divider(height: 40),
        // Shelves selection
        Text(
          'Shelves Promotion',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: _isFeatured,
              onChanged: (val) {
                if (val != null) setState(() => _isFeatured = val);
              },
              activeColor: Theme.of(context).primaryColor,
            ),
            Text('PROMOTE TO FEATURED SHELF', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
            const SizedBox(width: 32),
            Checkbox(
              value: _isTrending,
              onChanged: (val) {
                if (val != null) setState(() => _isTrending = val);
              },
              activeColor: Theme.of(context).primaryColor,
            ),
            Text('PROMOTE TO TRENDING SHELF', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 24),
        BlocBuilder<RecipeEditorBloc, RecipeEditorState>(
          builder: (context, state) {
            final isSaving = state is RecipeEditorSaving;
            return isSaving
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildStatSummary(String label, String value) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildNavigationFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlineBtn(
            label: 'Back',
            onPressed: _currentStep > 1 ? _onBack : null,
          ),
          _currentStep == 6
              ? PrimaryButton(
                  label: widget.recipeId == null ? 'Save and Publish Recipe' : 'Update Recipe Details',
                  onPressed: _onSaveAndSubmit,
                )
              : PrimaryButton(
                  label: 'Next Step',
                  onPressed: _onNext,
                ),
        ],
      ),
    );
  }
}
