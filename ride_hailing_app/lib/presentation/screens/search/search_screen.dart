import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';
import '../../../data/providers/providers.dart';
import '../../../data/models/models.dart';
import '../../widgets/widgets.dart';

/// Destination search screen
class SearchScreen extends ConsumerStatefulWidget {
  final SavedPlaceType? savedPlaceType;

  const SearchScreen({
    super.key,
    this.savedPlaceType,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    ref.read(locationProvider.notifier).searchLocations(query);
  }

  void _onLocationSelected(LocationModel location) {
    if (widget.savedPlaceType != null) {
      // Updating a saved place
      final savedPlace = widget.savedPlaceType == SavedPlaceType.home
          ? SavedPlace.home(location: location)
          : SavedPlace.work(location: location);
      ref.read(locationProvider.notifier).updateSavedPlace(savedPlace);
      context.pop();
    } else {
      // Setting destination
      ref.read(locationProvider.notifier).setDestinationLocation(location);
      context.pushReplacement('/ride-options');
    }
  }

  void _onSavedPlaceTap(SavedPlace place) {
    if (place.isSet && place.location != null) {
      _onLocationSelected(place.location!);
    }
  }

  void _onRecentPlaceTap(RecentPlace recentPlace) {
    _onLocationSelected(recentPlace.location);
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(locationProvider.notifier).clearSearchResults();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final hasSearchQuery = _searchController.text.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with search inputs
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.overlayLight,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Back button and route inputs
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          children: [
                            // Pickup Location (fixed)
                            _LocationInput(
                              isPickup: true,
                              value: locationState.pickupLocation?.shortAddress ??
                                  'Current location',
                              isEditable: false,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            // Destination Input
                            _LocationInput(
                              isPickup: false,
                              controller: _searchController,
                              focusNode: _focusNode,
                              hintText: widget.savedPlaceType != null
                                  ? 'Set ${widget.savedPlaceType == SavedPlaceType.home ? 'home' : 'work'} address'
                                  : AppStrings.whereTo,
                              onChanged: _onSearchChanged,
                              onClear: hasSearchQuery ? _clearSearch : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Search Results / Content
            Expanded(
              child: hasSearchQuery
                  ? _SearchResults(
                      results: locationState.searchResults,
                      isLoading: locationState.isLoading,
                      onLocationTap: _onLocationSelected,
                    )
                  : _DefaultContent(
                      savedPlaces: locationState.savedPlaces,
                      recentPlaces: locationState.recentPlaces,
                      onSavedPlaceTap: _onSavedPlaceTap,
                      onRecentPlaceTap: _onRecentPlaceTap,
                      showSavedPlaces: widget.savedPlaceType == null,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationInput extends StatelessWidget {
  final bool isPickup;
  final String? value;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final bool isEditable;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const _LocationInput({
    required this.isPickup,
    this.value,
    this.controller,
    this.focusNode,
    this.hintText,
    this.isEditable = true,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Indicator dot/square
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: isPickup ? AppColors.textSecondary : AppColors.textPrimary,
            shape: isPickup ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isPickup ? null : BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Input field
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.divider.withOpacity(0.5),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: isEditable
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          focusNode: focusNode,
                          style: AppTypography.bodyMedium,
                          decoration: InputDecoration(
                            hintText: hintText,
                            hintStyle: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          onChanged: onChanged,
                        ),
                      ),
                      if (onClear != null)
                        GestureDetector(
                          onTap: onClear,
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value ?? '',
                      style: AppTypography.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _SearchResults extends StatelessWidget {
  final List<LocationModel> results;
  final bool isLoading;
  final ValueChanged<LocationModel> onLocationTap;

  const _SearchResults({
    required this.results,
    required this.isLoading,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No results found',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: results.length,
      separatorBuilder: (_, __) => const Divider(indent: 72),
      itemBuilder: (context, index) {
        final location = results[index];
        return LocationCard(
          location: location,
          onTap: () => onLocationTap(location),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        );
      },
    );
  }
}

class _DefaultContent extends StatelessWidget {
  final List<SavedPlace> savedPlaces;
  final List<RecentPlace> recentPlaces;
  final ValueChanged<SavedPlace> onSavedPlaceTap;
  final ValueChanged<RecentPlace> onRecentPlaceTap;
  final bool showSavedPlaces;

  const _DefaultContent({
    required this.savedPlaces,
    required this.recentPlaces,
    required this.onSavedPlaceTap,
    required this.onRecentPlaceTap,
    this.showSavedPlaces = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      children: [
        // Saved Places
        if (showSavedPlaces && savedPlaces.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              AppStrings.savedPlaces,
              style: AppTypography.titleSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...savedPlaces.map((place) {
            return InkWell(
              onTap: () => onSavedPlaceTap(place),
              child: Padding(
                padding: AppSpacing.listItemPadding,
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusSm,
                        ),
                      ),
                      child: Icon(
                        place.type == SavedPlaceType.home
                            ? Icons.home_outlined
                            : Icons.work_outline,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            style: AppTypography.titleSmall,
                          ),
                          if (place.isSet) ...[
                            const SizedBox(height: 2),
                            Text(
                              place.location!.shortAddress,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ] else ...[
                            const SizedBox(height: 2),
                            Text(
                              'Add ${place.name.toLowerCase()}',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.info,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
        ],
        // Recent Places
        if (recentPlaces.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              AppStrings.recentPlaces,
              style: AppTypography.titleSmall,
            ),
          ),
          ...recentPlaces.map((place) {
            return RecentLocationItem(
              recentPlace: place,
              onTap: () => onRecentPlaceTap(place),
            );
          }),
        ],
      ],
    );
  }
}
