import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'package:fraseapp/core/core.dart';
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
    final colorsScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final bool isDarkMode = ref.watch( themeNotifierProvider ).isDarkMode;

    if ( !isLoading ) {

      return Center(
        child:  CircularProgressIndicator(
          strokeWidth: 2, 
          color: isDarkMode ? colorsScheme.surface : colorsScheme.primary
        )
      );

    } else {

      if ( favoritePhrases.isEmpty ) {

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon( Icons.favorite_outline_sharp, size: 70, color: colorsScheme.primary ),
              Text('Oppss!!', style: TextStyle(fontSize: 30, color: colorsScheme.primary) ),

              const SizedBox(height: 10),

              const Text('No tienes Frases favoritas.', style: TextStyle(fontSize: 20, color: Colors.black45)),

              const SizedBox(height: 30),

              FilledButton.tonal(
                onPressed: () => context.go('/'),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all( isDarkMode ? Colors.black87 : colorsScheme.primary ),
                  foregroundColor: WidgetStateProperty.all( Colors.white ) 
                ), 
                child: const Text('Ver frase del dia'),
              )
            ],
          ),
        );

      }

      return CustomScrollView(
        slivers: [

          SliverAppBar(
            toolbarHeight: size.height * 0.11,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Lista de favoritos: ${ favoritePhrases.length }', 
                style: TextStyle( 
                  fontSize: 20, 
                  color: colorsScheme.brightness == Brightness.light ? colorsScheme.primary : colorsScheme.surface, 
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
              child: const Text('Cerrar')
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
        return AlertDialog(
          title: Center(child: Text("¿?", style: textStyles.titleMedium,)),
          content: Text("¿Estás seguro de eliminar esta frase?", style: textStyles.titleSmall, textAlign: TextAlign.center,),

          actions: [
            TextButton(
              onPressed: () {
                dismiss = true;
                Navigator.pop(context);
              },
              child: const Text("Si"),
            ),
            FilledButton(
              onPressed: () {
                dismiss = false;
                Navigator.pop(context);
              },
              child: const Text("No")
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
      background: Container(color: Colors.white),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: const Icon( Icons.delete_outline, color: Colors.white ),
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
          }
          return response;
        }
        return false;
      },
      dismissThresholds: const {
        DismissDirection.endToStart: 0.5
      },
      key: UniqueKey(), 
      direction: DismissDirection.endToStart,
      child: GestureDetector(
        onTap: ()  => openDialogPhrase(context, isDarkMode, colorsTheme),
        child: ListTile(
          title: Text(
            favorite['phrase'].toString().length >= 25 
            ? '${ favorite['phrase'].toString().substring(0, 24) }...' 
            : favorite['phrase'].toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: colorsScheme.brightness == Brightness.light ? colorsScheme.secondary : colorsScheme.surface 
            ),
          ),
          subtitle: Text( 
            favorite['author'], 
            style: TextStyle( color: colorsScheme.brightness == Brightness.light ? colorsScheme.secondary : colorsScheme.surface ), ),
          leading: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.white),
              borderRadius: BorderRadius.circular(10),
              color: Color( (math.Random().nextDouble() * 0xFFFFFF).toInt() ).withOpacity(1.0),
            ),
            child: Container(
              padding: const EdgeInsets.all(15.0),
              child: const Icon( Icons.list_alt_outlined, color: Colors.white, size: 18.0 ),
            ),
          ),
        ),
      )
    );
  }

}