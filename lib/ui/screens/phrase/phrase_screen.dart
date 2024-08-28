import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:fraseapp/config/config.dart';
import 'package:fraseapp/core/core.dart';
import 'package:fraseapp/shared/shared.dart';

class PhraseScreen extends ConsumerWidget {

  final PhraseEntitie favorite;

  const PhraseScreen({
    super.key, 
    required this.favorite
  });

  /// view notifications in snackbar
  void showSnackbarNotification( String messsage, BuildContext context ) {

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(messsage),
        duration: const Duration(seconds: 2),
      )
    );

  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final textStyles = Theme.of(context).textTheme;
    final favoritesProvider = ref.watch( favoritesPhrasesProvider.notifier );
    final isFavoriteFuture = ref.watch( isPhraseFavoriteProvider( favorite.phrase ) );

    return Stack(
      children: [

        /// Image
        SizedBox.expand(
          child: Image.network(
            favorite.image,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              return child;
            },
            errorBuilder: (context, error, stackTrace) {
              return Image.asset('assets/images/default_image.jpg', fit: BoxFit.cover);
            },
          )
        ),

        /// Gradient the image
        const _CustomGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 1.0],
          colors: [
            Colors.black45,
            Colors.black45
          ]
        ),

        /// Phrase
        SizedBox.expand(
          child: Container(
            padding: const EdgeInsets.symmetric( horizontal: 10 ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            
                Text( '"${favorite.phrase}"', 
                      style: textStyles.titleSmall!.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                ),
          
                const SizedBox(
                  height: 50,
                ),

                TextButton(
                  onPressed: () async {
                    final url = '${ Environments.urlWikipedia }/${ favorite.author }';
                    await openUrl(url); 
                  }, 
                  child: Text( favorite.author, 
                      style: textStyles.titleSmall!.copyWith(
                        color: const Color.fromARGB(190, 255, 255, 255),
                        decoration: TextDecoration.underline,
                        decorationColor: const Color.fromARGB(190, 255, 255, 255),
                      ),
                      textAlign: TextAlign.center,
                  )
                )
            
              ],
            ),
          )
        ),        

        /// icon favorite
        Positioned(
          top: 10,
          right: 0,
          child: IconButton(
            onPressed: () async {
              await favoritesProvider.tooglePhraseFavorite( favorite );
              ref.invalidate( isPhraseFavoriteProvider( favorite.phrase ) );
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
              
              final isFavorite = await favoritesProvider.isPhraseFavorite( favorite.phrase );
              if ( !context.mounted ) return;
              if ( isFavorite ) {
                
                showSnackbarNotification( 'Agregado a favoritos', context );
                final timeExpirationRequestNotification = await ref.read( favoritesPhrasesProvider.notifier ).getTimeToRequestNotification();
                if ( timeExpirationRequestNotification != 'null' ) {
                  final timeExpiration = DateTime.parse(timeExpirationRequestNotification);
                  if ( timeExpiration.isBefore( DateTime.now() ) ) {
                    ref.read( favoritesPhrasesProvider.notifier ).setOrDeleteWaitingTimeToRequestNotification(
                      RequestNotification.approved
                    );
                    if ( !context.mounted ) return;
                    LocalNotifications.requestPermissionsLocalNotifications( context, textStyles );
                  }
                } else {
                  if ( !context.mounted ) return;
                  LocalNotifications.requestPermissionsLocalNotifications( context, textStyles );
                }

              } else {

                // sorting phrases
                // final order = ref.read(typeOrderPhraseProvider.notifier).state;
                if ( order == TypeOrder.defect ) {
                  ref.read(favoritesPhrasesProvider).sort((a, b) {
                    return DateTime.parse( a['date'].toString() ).isBefore( DateTime.parse( b['date'].toString() )) ? -1 : 1;
                  });
                } else {
                  ref.read(favoritesPhrasesProvider).sort((a, b) {
                    return DateTime.parse( a['date'].toString() ).isBefore( DateTime.parse( b['date'].toString() )) ? 1 : -1;
                  });
                }
                if ( ref.read(favoritesPhrasesProvider).isEmpty ) ref.read(typeOrderPhraseProvider.notifier).state = TypeOrder.date;

              }
            }, 
            icon: isFavoriteFuture.when(
              loading: () => const CircularProgressIndicator(strokeWidth: 2),
              data: (isFavorite) => isFavorite 
              ? const Icon( Icons.favorite_rounded, color: Colors.red )  
              : const Icon( Icons.favorite_border ), 
              error: (_, stackTrace) => throw UnimplementedError(), 
              skipLoadingOnRefresh: false
            ),
            color: Colors.white,
          )
        ),

        /// icon share
        Positioned(
          top: 10,
          left: 0,
          child: IconButton(
            onPressed: (){
              toShare('"${favorite.phrase}" ✍🏼 ${favorite.author}');
            }, 
            icon: const Icon(Icons.share),
            color: Colors.white,
          )
        ),

      ],
    );
  }
}


class _CustomGradient extends StatelessWidget {

  // begin
  final AlignmentGeometry begin;
  // end
  final AlignmentGeometry? end;
  // stops
  final List<double> stops;
  // colors
  final List<Color> colors;

  const _CustomGradient({
    required this.begin, 
    required this.stops, 
    required this.colors,
    this.end = Alignment.centerRight
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end!,
            stops: stops,
            colors: colors
          )
        ),
      ),
    );
  }
}