import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fraseapp/core/core.dart';
import 'package:fraseapp/shared/shared.dart';
import 'package:fraseapp/ui/screens/phrase/phrase_screen.dart';
import 'package:go_router/go_router.dart';

class FavoriteScreen extends ConsumerStatefulWidget {
  const FavoriteScreen({super.key});

  @override
  FavoriteScreenState createState() => FavoriteScreenState();
}

class FavoriteScreenState extends ConsumerState<FavoriteScreen> {

  bool isLoading = false;

  loadfavoritesPhrases() async {
    isLoading = false;
    await ref.read( favoritesPhrasesProvider.notifier ).getPhrasesFavorites();
    isLoading = true;
  }

  @override
  void initState() {
    super.initState();

    loadfavoritesPhrases();
  }

  @override
  Widget build(BuildContext context) {

    final favoritePhrases = ref.watch( favoritesPhrasesProvider );
    final order = ref.watch( typeOrderPhraseProvider );
    final colorsScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final bool isDarkMode = ref.watch( themeNotifierProvider ).isDarkMode;

    if ( !isLoading ) {

      return Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colorsScheme.primary,
        ),
      );

    } else {

      if ( favoritePhrases.isEmpty ) {

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon( Icons.favorite_outline_sharp, size: 70, color: colorsScheme.primary ),
              const SizedBox(height: 12),
              Text(
                'Sin favoritos aún',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colorsScheme.primary,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Guarda las frases que más te gusten para verlas aquí.',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode
                      ? colorsScheme.onSurface.withValues(alpha: 0.7)
                      : Colors.black45,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              FilledButton.tonal(
                onPressed: () => context.go('/'),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(colorsScheme.primary),
                  foregroundColor: WidgetStateProperty.all(colorsScheme.onPrimary),
                ),
                child: const Text('Ver frase del día'),
              )
            ],
          ),
        );

      }

      return Scaffold(
        body: CustomScrollView(
          slivers: [
        
            SliverAppBar(
              toolbarHeight: size.height * 0.1,
              floating: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Favoritos · ${favoritePhrases.length}',
                  style: TextStyle( 
                    fontSize: 20, 
                    color: colorsScheme.primary,
                    fontWeight: FontWeight.bold 
                  )
                ),
                titlePadding: const EdgeInsets.symmetric(vertical: 20.0),
                centerTitle: true,
              ),
              automaticallyImplyLeading: false
            ),
        
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Column(
                    children: [
                      _CustomListFavorites(favorites: favoritePhrases)
                    ],
                  );
                },
                childCount: 1
              )
            )
        
          ],
        ),
        floatingActionButton: favoritePhrases.length > 1 
        ? FloatingActionButton(
          tooltip: 'Ordenar por fecha',
          onPressed: (){
            if ( order == TypeOrder.defect ) {
              favoritePhrases.sort((a, b) {
                return DateTime.parse( a['date'].toString() ).isBefore( DateTime.parse( b['date'].toString() )) ? 1 : -1;
              });
              ref.read(typeOrderPhraseProvider.notifier).state = TypeOrder.date;
            } else {
              favoritePhrases.sort((a, b) {
                return DateTime.parse( a['date'].toString() ).isBefore( DateTime.parse( b['date'].toString() )) ? -1 : 1;
              });
              ref.read(typeOrderPhraseProvider.notifier).state = TypeOrder.defect;
            }
            setState(() {});
          },
          child: const Icon(Icons.low_priority_outlined),
        ) 
        : null,
      );

    }

  }

}

class _CustomListFavorites extends StatelessWidget {

  final List<dynamic> favorites;

  const _CustomListFavorites({
    required this.favorites
  });

  @override
  Widget build(BuildContext context) {

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: favorites.length,
      itemBuilder: (BuildContext context, int index) {
        final favorite = favorites[index];
        return _CustomDismissibleFavorite(favorite: favorite);
      },
    );
  }

}

class _CustomDismissibleFavorite extends ConsumerWidget {

  final Map<String, dynamic> favorite;

  const _CustomDismissibleFavorite({ required this.favorite });

  /// open a favorite phrase in the dialogue
  void openDialogPhrase(BuildContext context, bool isDarkMode, ColorScheme colorsTheme) {

    favorite['date'] = ( favorite['date'] is DateTime ) ? favorite['date'] : DateTime.parse( favorite['date'] );

    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          appBar: AppBar(
            title: FilledButton.tonal(
              onPressed: () => Navigator.pop(context),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(Colors.white),
              ),
              child: const Text('Cerrar'),
            ),
            centerTitle: true,
            backgroundColor: isDarkMode ? colorsTheme.surface : colorsTheme.primary,
            automaticallyImplyLeading: false,
          ),
          body: PhraseScreen(favorite: PhraseMapper.jsonToEntity(favorite))
        );
      }
    );
    
  }

  Future<bool> openDialogQuestionDeletePhrase( BuildContext context, TextTheme textStyles ) async {

    bool dismiss = false;

    await showDialog(
      context: context, 
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Column(
            children: [
              Icon(Icons.delete_outline, size: 36, color: colors.error),
              const SizedBox(height: 8),
              Text('Eliminar favorito', style: textStyles.titleSmall),
            ],
          ),
          content: Text(
            '¿Estás seguro de eliminar esta frase de favoritos?',
            style: textStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                dismiss = true;
                Navigator.pop(context);
              },
              child: const Text('Eliminar'),
            ),
            FilledButton(
              onPressed: () {
                dismiss = false;
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );

    return dismiss;

  } 
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final colorsScheme = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final colorsTheme = Theme.of(context).colorScheme;
    final bool isDarkMode = ref.watch( themeNotifierProvider ).isDarkMode;

    return Dismissible(
      background: Container(
        color: colorsScheme.primary,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Icon(Icons.share_outlined, color: colorsScheme.onPrimary),
      ),
      secondaryBackground: Container(
        color: colorsScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Icon(Icons.delete_outline, color: colorsScheme.onError),
      ), 
      confirmDismiss:(direction) async {
        if ( direction == DismissDirection.endToStart ) {
          final response = await openDialogQuestionDeletePhrase(context, textStyles);
          if ( response ) {

            favorite['date'] = ( favorite['date'] is DateTime ) ? favorite['date'] : DateTime.parse( favorite['date'] );
            final PhraseEntitie phrase = PhraseMapper.jsonToEntity( favorite );
            await ref.read( favoritesPhrasesProvider.notifier ).tooglePhraseFavorite( phrase );
            ref.invalidate( isPhraseFavoriteProvider( favorite['phrase'] ) );
            await ref.read( favoritesPhrasesProvider.notifier ).getPhrasesFavorites( toDelay: false );

            // sorting phrases 
            final order = ref.read(typeOrderPhraseProvider.notifier).state;
            if ( order == TypeOrder.defect ) {
              ref.read(favoritesPhrasesProvider).sort((a, b) {
                return DateTime.parse( a['date'].toString() ).isBefore( DateTime.parse( b['date'].toString() )) ? -1 : 1;
              });
            } else {
              ref.read(favoritesPhrasesProvider).sort((a, b) {
                return DateTime.parse( a['date'].toString() ).isBefore( DateTime.parse( b['date'].toString() )) ? 1 : -1;
              });
            }

          }
          return response;
        } else {
          await toShare('"${favorite['phrase']}" ✍🏼 ${favorite['author']}');
          return false;
        }
      },
      dismissThresholds: const {
        DismissDirection.endToStart: 0.5,
        DismissDirection.startToEnd: 0.5,
      },
      key: UniqueKey(),
      child: GestureDetector(
        onTap: ()  => openDialogPhrase(context, isDarkMode, colorsTheme),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            favorite['phrase'].toString().length >= 25 
            ? '${ favorite['phrase'].toString().substring(0, 24) }...' 
            : favorite['phrase'].toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorsScheme.onSurface,
            ),
          ),
          subtitle: Text(
            favorite['author'],
            style: TextStyle(
              color: colorsScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: Image.network(
                favorite['image']?.toString() ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/default_image.jpg',
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
        ),
      )
    );
  }

}