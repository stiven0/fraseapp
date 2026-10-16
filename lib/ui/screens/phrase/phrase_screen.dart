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
        behavior: SnackBarBehavior.floating,
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
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.black87,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white54,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Image.asset('assets/images/default_image.jpg', fit: BoxFit.cover);
            },
          )
        ),

        /// Cinematic scrim: darker at top/bottom for icons and text
        const _CustomGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.35, 0.65, 1.0],
          colors: [
            Color(0x99000000),
            Color(0x33000000),
            Color(0x33000000),
            Color(0xB3000000),
          ],
        ),

        /// Phrase
        SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '"${favorite.phrase}"',
                  style: textStyles.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    shadows: const [
                      Shadow(
                        blurRadius: 16,
                        color: Color(0x99000000),
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                TextButton(
                  onPressed: () async {
                    final url = '${Environments.urlWikipedia}/${Uri.encodeComponent(favorite.author)}';
                    await openUrl(url);
                  },
                  child: Text(
                    favorite.author,
                    style: textStyles.titleSmall?.copyWith(
                      color: const Color(0xD9FFFFFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xD9FFFFFF),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),

        /// Share + favorite actions
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      toShare('"${favorite.phrase}" ✍🏼 ${favorite.author}');
                    },
                    icon: const Icon(Icons.share),
                    color: Colors.white,
                  ),
                  IconButton(
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
                      loading: () => const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                      ),
                      data: (isFavorite) => isFavorite 
                      ? const Icon( Icons.favorite_rounded, color: Colors.red )  
                      : const Icon( Icons.favorite_border ), 
                      error: (_, stackTrace) => throw UnimplementedError(), 
                      skipLoadingOnRefresh: false
                    ),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
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
