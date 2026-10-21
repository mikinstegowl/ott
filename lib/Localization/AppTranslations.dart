import 'package:get/get.dart';

/// Every word the app says, in each language it speaks.
///
/// Uses GetX's own translation support rather than adding a package: GetX is
/// already here, and this needs no code generation step, so a new string is
/// one line in each map.
///
/// A key missing from Spanish falls back to English rather than printing the
/// key at the viewer, which is handled by [AppTranslations.resolve].
class AppTranslations extends Translations {
  static const english = 'en';
  static const spanish = 'es';

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': _en,
        'es_419': _es,
      };

  /// Spanish with no translation yet reads the English rather than the key.
  static String resolve(String key) {
    final value = key.tr;

    if (value != key) return value;

    return _en[key] ?? key;
  }

  static const Map<String, String> _en = {
    // ── Navigation ──
    'nav.home': 'Home',
    'nav.live_video': 'Live Video',
    'nav.search': 'Search',
    'nav.tv_shows': 'TV Shows',
    'nav.profile': 'Profile',

    // ── Common ──
    'common.watch_now': 'Watch Now',
    'common.play_now': 'Play Now',
    'common.load_more': 'Load More',
    'common.retry': 'Retry',
    'common.cancel': 'Cancel',
    'common.close': 'Close',
    'common.continue': 'Continue',
    'common.yes': 'Yes',
    'common.no': 'No',
    'common.save': 'Save',
    'common.share': 'Share',
    'common.something_went_wrong': 'Something went wrong',

    // ── Sign in and sign up ──
    'auth.email_address': 'Email Address',
    'auth.enter_email': 'Enter email',
    'auth.password': 'Password',
    'auth.login': 'Login',
    'auth.if_you_are_new': 'If you are new? ',
    'auth.sign_up': 'Sign Up',
    'auth.or': 'OR',
    'auth.continue_with_subscription': 'Continue with subscription login',
    'auth.full_name': 'Full Name',
    'auth.enter_name': 'Enter name',
    'auth.phone_optional': 'Phone (optional)',
    'auth.enter_phone': 'Enter phone',
    'auth.confirm_password': 'Confirm Password',
    'auth.confirm_password_hint': 'Confirm password',
    'auth.already_have_account': 'Already have an account? ',
    'auth.sign_in': 'Sign In',
    'auth.fill_required': 'Please fill all required fields',
    'auth.passwords_no_match': 'Passwords do not match',
    'auth.registration_successful': 'Registration Successful',
    'auth.registration_failed': 'Registration Failed',
    'auth.login_failed': 'Login failed',

    // ── Profile ──
    'profile.title': 'My Profile',
    'profile.none_found': 'No profile data found',
    'profile.user_name': 'User Name',
    'profile.personal_information': 'Personal Information',
    'profile.change_password': 'Change Password',
    'profile.current_password': 'Current Password',
    'profile.new_password': 'New Password',
    'profile.update_profile': 'Update Profile',
    'profile.log_out': 'Log Out',
    'profile.delete_account': 'Delete Account',
    'profile.no_active_plan': 'No Active Plan',
    'profile.max_quality': 'Max Quality',
    'profile.max_screens': 'Max Screens',
    'profile.phone_number': 'Phone Number',
    'profile.preferred_quality': 'Preferred Quality',
    'profile.language': 'Language',
    'profile.updated': 'Profile updated successfully',
    'profile.load_failed': 'Failed to load profile',
    'profile.current_password_required': 'Current password is required to change password',

    // ── Content ──
    'content.synopsis': 'Synopsis',
    'content.cast_crew': 'Cast & Crew',
    'content.season': 'Season @number',
    'content.episode_prefix': 'E@number',
    'content.continue_watching': 'Continue Watching EP. @number',

    // ── Paywall and purchases ──
    'paywall.choose_plan': 'Choose your plan',
    'paywall.rent_or_buy': 'Rent or buy',
    'paywall.rent_or_buy_title': 'Rent or buy @title',
    'paywall.full_catalogue': 'Watch the full catalogue on any device',
    'paywall.one_payment': 'One payment — no subscription needed',
    'paywall.no_products': 'No products found',
    'paywall.check_store': 'Please check your Store setup or try again later.',
    'paywall.restore': 'Restore Purchases',
    'paywall.terms': 'Terms of Use',
    'paywall.privacy': 'Privacy Policy',
    'purchase.could_not_start': 'Could not initiate purchase. Please try again.',
    'purchase.checking_previous': 'Checking for previous purchases...',
    'purchase.restored': 'Your purchases have been restored!',
    'purchase.thank_you': 'Thank you! Your purchase was completed.',
    'purchase.could_not_verify': 'Could not verify purchase with server. Please contact support.',
    'purchase.cancelled_or_failed': 'Purchase was cancelled or failed.',
    'purchase.could_not_confirm': 'We could not confirm that purchase.',
    'purchase.offline':
        'We could not reach the server. Your purchase is safe — open the app again, or use Restore Purchases.',

    // ── Ads ──
    'ads.label': 'Ad',
    'ads.visit_advertiser': 'Visit advertiser',
    'ads.skip': 'Skip ad',
    'ads.skip_in': 'Skip in @seconds',

    // ── Search and lists ──
    'search.hint': 'Search movies, series and more',
    'search.no_results': 'No results found',
    'watchlist.title': 'My Watchlist',
    'watchlist.empty': 'Your watchlist is empty',

    // ── App shell ──
    'app.exit_title': 'Exit App',
    'app.exit_message': 'Are you sure you want to exit the app?',
    'app.continue_as': 'Continue as @name',
    'app.guest': 'Guest',
  };

  static const Map<String, String> _es = {
    'nav.home': 'Inicio',
    'nav.live_video': 'En vivo',
    'nav.search': 'Buscar',
    'nav.tv_shows': 'Series',
    'nav.profile': 'Perfil',

    'common.watch_now': 'Ver ahora',
    'common.play_now': 'Reproducir',
    'common.load_more': 'Cargar más',
    'common.retry': 'Reintentar',
    'common.cancel': 'Cancelar',
    'common.close': 'Cerrar',
    'common.continue': 'Continuar',
    'common.yes': 'Sí',
    'common.no': 'No',
    'common.save': 'Guardar',
    'common.share': 'Compartir',
    'common.something_went_wrong': 'Algo salió mal',

    'auth.email_address': 'Correo electrónico',
    'auth.enter_email': 'Escribe tu correo',
    'auth.password': 'Contraseña',
    'auth.login': 'Iniciar sesión',
    'auth.if_you_are_new': '¿Eres nuevo? ',
    'auth.sign_up': 'Crear cuenta',
    'auth.or': 'O',
    'auth.continue_with_subscription': 'Continuar con inicio de sesión de suscripción',
    'auth.full_name': 'Nombre completo',
    'auth.enter_name': 'Escribe tu nombre',
    'auth.phone_optional': 'Teléfono (opcional)',
    'auth.enter_phone': 'Escribe tu teléfono',
    'auth.confirm_password': 'Confirmar contraseña',
    'auth.confirm_password_hint': 'Confirmar contraseña',
    'auth.already_have_account': '¿Ya tienes una cuenta? ',
    'auth.sign_in': 'Iniciar sesión',
    'auth.fill_required': 'Completa todos los campos obligatorios',
    'auth.passwords_no_match': 'Las contraseñas no coinciden',
    'auth.registration_successful': 'Cuenta creada',
    'auth.registration_failed': 'No se pudo crear la cuenta',
    'auth.login_failed': 'No se pudo iniciar sesión',

    'profile.title': 'Mi perfil',
    'profile.none_found': 'No se encontraron datos del perfil',
    'profile.user_name': 'Nombre de usuario',
    'profile.personal_information': 'Información personal',
    'profile.change_password': 'Cambiar contraseña',
    'profile.current_password': 'Contraseña actual',
    'profile.new_password': 'Nueva contraseña',
    'profile.update_profile': 'Actualizar perfil',
    'profile.log_out': 'Cerrar sesión',
    'profile.delete_account': 'Eliminar cuenta',
    'profile.no_active_plan': 'Sin plan activo',
    'profile.max_quality': 'Calidad máxima',
    'profile.max_screens': 'Pantallas máximas',
    'profile.phone_number': 'Número de teléfono',
    'profile.preferred_quality': 'Calidad preferida',
    'profile.language': 'Idioma',
    'profile.updated': 'Perfil actualizado',
    'profile.load_failed': 'No se pudo cargar el perfil',
    'profile.current_password_required': 'Necesitas tu contraseña actual para cambiarla',

    'content.synopsis': 'Sinopsis',
    'content.cast_crew': 'Reparto y equipo',
    'content.season': 'Temporada @number',
    'content.episode_prefix': 'E@number',
    'content.continue_watching': 'Seguir viendo EP. @number',

    'paywall.choose_plan': 'Elige tu plan',
    'paywall.rent_or_buy': 'Alquilar o comprar',
    'paywall.rent_or_buy_title': 'Alquilar o comprar @title',
    'paywall.full_catalogue': 'Mira todo el catálogo en cualquier dispositivo',
    'paywall.one_payment': 'Un solo pago, sin suscripción',
    'paywall.no_products': 'No se encontraron productos',
    'paywall.check_store': 'Revisa la configuración de la tienda o inténtalo más tarde.',
    'paywall.restore': 'Restaurar compras',
    'paywall.terms': 'Términos de uso',
    'paywall.privacy': 'Política de privacidad',
    'purchase.could_not_start': 'No se pudo iniciar la compra. Inténtalo de nuevo.',
    'purchase.checking_previous': 'Buscando compras anteriores...',
    'purchase.restored': '¡Tus compras se han restaurado!',
    'purchase.thank_you': '¡Gracias! Tu compra se completó.',
    'purchase.could_not_verify': 'No se pudo verificar la compra con el servidor. Contacta con soporte.',
    'purchase.cancelled_or_failed': 'La compra se canceló o falló.',
    'purchase.could_not_confirm': 'No pudimos confirmar esa compra.',
    'purchase.offline':
        'No pudimos conectar con el servidor. Tu compra está a salvo: vuelve a abrir la app o usa Restaurar compras.',

    'ads.label': 'Anuncio',
    'ads.visit_advertiser': 'Visitar anunciante',
    'ads.skip': 'Saltar anuncio',
    'ads.skip_in': 'Saltar en @seconds',

    'search.hint': 'Busca películas, series y más',
    'search.no_results': 'No se encontraron resultados',
    'watchlist.title': 'Mi lista',
    'watchlist.empty': 'Tu lista está vacía',

    'app.exit_title': 'Salir de la app',
    'app.exit_message': '¿Seguro que quieres salir de la app?',
    'app.continue_as': 'Continuar como @name',
    'app.guest': 'Invitado',
  };
}
