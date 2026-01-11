// lib/presentation/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tugas_akhir/presentation/screens/auth/login_screen.dart';
import 'package:tugas_akhir/presentation/screens/auth/register_screen.dart';
// import 'package:tugas_akhir/presentation/screens/auth/salon_auth_screen.dart';

//customer screen
import 'package:tugas_akhir/presentation/screens/customer/address_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/address_add_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/address_edit_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/home_screen.dart';
import 'package:tugas_akhir/presentation/screens/common/splash_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/notification_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/profile_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/pet_list_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/booking_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/pet_add_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/pet_edit_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/pet_detail_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/medical_pet_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/add_medical_record_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/booking_new_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/booking_detail_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/personal_data_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/service_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/service_detail_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/service_metode_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/service_metode_detail_screen.dart';
import 'package:tugas_akhir/presentation/screens/customer/help_screen.dart';
import 'package:tugas_akhir/core/models/address_model.dart';

//model
import 'package:tugas_akhir/core/models/user_model.dart';
import 'package:tugas_akhir/core/models/pet_model.dart';
import 'package:tugas_akhir/core/models/layanan_model.dart';

//admin screen
// import 'package:tugas_akhir/presentation/screens/auth/role_selection_screen.dart';
// import 'package:tugas_akhir/presentation/screens/auth/admin-driver_login_screen.dart';
// import 'package:tugas_akhir/presentation/screens/auth/admin_login_screen.dart';
// import 'package:tugas_akhir/presentation/screens/auth/admin_regis_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/dashboard_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/bookings_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/layanan_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/customer_screen.dart';
import 'package:tugas_akhir/presentation/screens/drivers/dashboard_drivers_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/payments_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/reports_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/riviews_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/settings_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/security_privacy_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/backup_restore_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/receipt_templates_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/admin_management_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/layanan_add_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/layanan_edit_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/bookings_add_manual_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/customer_detail_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/pet_list_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/customer_edit_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/pet_edit_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/pet_add_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/bookings_detail_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/drivers_add_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/drivers_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/admin_add_staff_screen.dart';
import 'package:tugas_akhir/presentation/screens/admin/layanan_detail_screen.dart';

class AppRouter {
  static final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // // Role Selection
        // GoRoute(
        //   path: '/role-selection',
        //   name: 'role-selection',
        //   pageBuilder: (context, state) => const MaterialPage(
        //     child: RoleSelectionScreen(),
        //   ),
        // ),

        // //Login Regisnya Admin-driver
        // GoRoute(
        //   path: '/salon-auth',
        //   name: 'salon-auth',
        //   pageBuilder: (context, state) => const MaterialPage(
        //     child: SalonAuthScreen(),
        //   ),
        // ),

        // //=================== Adminnn ===================//
        // //Login Sebagai admin
        // GoRoute(
        //   path: '/admin/login',
        //   name: 'admin-login',
        //   pageBuilder: (context, state) => const MaterialPage(
        //     child: AdminLoginScreen(),
        //   ),
        // ),
        // //Regis Sebagai admin
        // GoRoute(
        //   path: '/admin/register',
        //   name: 'admin-register',
        //   pageBuilder: (context, state) => MaterialPage(
        //     child: AdminRegisterScreen(
        //       salonCode: state.uri.queryParameters['code'] ?? '',
        //     ),
        //   ),
        // ),

        // Admin Dashboard
        GoRoute(
          path: '/admin/dashboard',
          name: 'admin-dashboard',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const AdminDashboardScreen(),
          ),
        ),

        //Booking
        //admin bookings
        GoRoute(
          path: '/admin/bookings',
          name: 'admin-bookings',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const AdminBookingsScreen(),
          ),
        ),

        GoRoute(
          path: '/admin/bookings/add',
          builder: (context, state) => const AddManualBookingScreen(),
        ),

        // Route untuk detail booking
        GoRoute(
          path: '/admin/bookings/:bookingId',
          builder: (context, state) {
            final booking = state.extra as Map<String, dynamic>;
            return AdminBookingDetailScreen(booking: booking);
          },
        ),

        //admin manajemen layanan
        //Tampilan utama
        GoRoute(
          path: '/admin/services',
          name: 'admin-services',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const AdminServicesScreen(),
          ),
        ),

        GoRoute(
          path: '/admin/services/add',
          builder: (context, state) => const AddServiceScreen(),
        ),

        GoRoute(
          path: '/admin/services/:id/edit',
          builder: (context, state) {
            final service = state.extra as ServiceModel;
            return EditServiceScreen(service: service);
          },
        ),

        GoRoute(
          path: '/admin/services/:id',
          builder: (context, state) {
            final service = state.extra as ServiceModel;
            return AdminServiceDetailScreen(service: service);
          },
        ),

        //Bagian customer
        //Admin customer and Hewan
        GoRoute(
          path: '/admin/customers',
          name: 'admin-customers',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const AdminCustomersScreen(),
          ),
        ),

        // Customer routes
        GoRoute(
          path: '/admin/customers/:id',
          builder: (context, state) {
            final customer = state.extra as UserModel;
            return CustomerDetailScreen(customer: customer);
          },
        ),

        // GoRoute(
        //   path: '/admin/customers/:id/pets',
        //   builder: (context, state) {
        //     final customer = state.extra as Map<String, dynamic>;
        //     return ManagePetsScreen(customer: customer);
        //   },
        // ),

        // Manage pets
        GoRoute(
          path: '/admin/customers/:id/pets',
          builder: (context, state) {
            // ✅
            final customer = state.extra as UserModel;
            return ManagePetsScreen(customer: customer);
          },
        ),

        GoRoute(
          path: '/admin/customers/:id/edit',
          builder: (context, state) {
            final customer = state.extra as UserModel;
            return EditCustomerScreen(customer: customer);
          },
        ),

        //edit hewan
        // GoRoute(
        //   path: '/admin/customers/:customerId/pets/edit',
        //   builder: (context, state) {
        //     // Extra adalah Map yang berisi customer dan pet
        //     final extra = state.extra as Map<String, dynamic>;
        //     final customer = extra['customer'] as Map<String, dynamic>;
        //     final pet = extra['pet'] as Map<String, dynamic>;

        //     return AdminEditPetScreen(
        //       customer: customer,
        //       pet: pet,
        //     );
        //   },
        // ),

        // Edit pet (jika ada)
        GoRoute(
          path: '/admin/customers/:id/pets/edit',
          builder: (context, state) {
            // ✅ Data lebih kompleks
            final extra = state.extra as Map<String, dynamic>;
            final customer = extra['customer'] as UserModel;
            final pet = extra['pet'] as PetModel;
            return AdminEditPetScreen(pet: pet, customer: customer);
          },
        ),

        // // Route untuk tambah hewan admin
        // GoRoute(
        //   path: '/admin/customers/:customerId/pets/add',
        //   builder: (context, state) {
        //     final customer = state.extra as Map<String, dynamic>;
        //     return AdminAddPetScreen(customer: customer);
        //   },
        // ),

        GoRoute(
          path: '/admin/customers/:id/pets/add',
          builder: (context, state) {
            // ✅
            final customer = state.extra as UserModel;
            return AdminAddPetScreen(customer: customer);
          },
        ),

        //Bagian Driver
        //Tampilan utama driver di admin
        // GoRoute(
        //   path: '/driver/login',
        //   name: 'driver-login',
        //   pageBuilder: (context, state) => const MaterialPage(
        //     child: DriverLoginScreen(),
        //   ),
        // ),

        // Rute untuk admin drivers
        GoRoute(
          path: '/admin/drivers',
          name: 'admin_drivers', // nama route untuk admin_drivers
          builder: (context, state) => const AdminDriversScreen(),
        ),

        // Rute untuk tambah driver (sesuai dengan data Anda)
        GoRoute(
          path: '/admin/drivers/add',
          name: 'add_driver', // nama route untuk tambah driver
          builder: (context, state) => const AddDriverScreen(),
        ),

        // Rute untuk detail driver
        // GoRoute(
        //   path: '/admin/drivers/:driverId',
        //   name: 'driver_detail',
        //   builder: (context, state) {
        //     final driverId = state.pathParameters['driverId'];
        //     return DriverDetailScreen(driverId: driverId!);
        //   },
        // ),

        GoRoute(
          path: '/driver/dashboard',
          name: 'driver-dashboard',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return NoTransitionPage(
              key: state.pageKey,
              child: DriverDashboardScreen(loginData: extra),
            );
          },
        ),

        //Pembayaran
        GoRoute(
          path: '/admin/payments',
          name: 'admin-payments',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const AdminPaymentsScreen(),
          ),
        ),

        //Laporan
        GoRoute(
          path: '/admin/reports',
          builder: (context, state) => const AdminReportsScreen(),
        ),

        //ulasan
        GoRoute(
          path: '/admin/reviews',
          builder: (context, state) => const AdminReviewsScreen(),
        ),

        //Settings
        GoRoute(
          path: '/admin/settings',
          name: 'admin_settings',
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: const AdminSettingsScreen(),
          ),
        ),

        GoRoute(
          path: '/admin/settings/backup',
          name: 'backup_restore',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const BackupRestoreScreen(),
          ),
        ),

        GoRoute(
          path: '/admin/settings/security',
          name: 'security_privacy',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const SecurityPrivacyScreen(),
          ),
        ),

        GoRoute(
          path: '/admin/settings/receipts',
          name: 'receipt_templates',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const ReceiptTemplatesScreen(),
          ),
        ),

        GoRoute(
          path: '/admin/settings/admins',
          name: 'admin_management',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: const AdminManagementScreen(),
          ),
        ),

        GoRoute(
          path: '/admin/add-staff',
          builder: (context, state) => const AddStaffScreen(),
        ),

        //=================== Customer ===================//
        //login register customer
        //login
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),

        //register
        GoRoute(
          path: '/register',
          name: 'register',
          builder: (context, state) => const RegisterScreen(),
        ),

        //home Customer
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeScreen()),
        ),

        //Profile
        // Tambahkan route di dalam routes:
        GoRoute(
          path: '/profile',
          name: 'profile',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfileScreen()),
        ),

        //Halaman  Data Diri
        GoRoute(
          path: '/profile/personal',
          builder: (context, state) => const PersonalDataScreen(),
        ),

        //Halaman  Alamat
        GoRoute(
          path: '/profile/address',
          builder: (context, state) => const AddressScreen(),
        ),

        //Halaman  tambah alamat
        GoRoute(
          path: '/address/add',
          builder: (context, state) => const AddAddressScreen(),
        ),

        //Halaman ubah alamat
        GoRoute(
          path: '/address/edit',
          builder: (context, state) {
            final addressData =
                state.extra as AddressModel; // <-- CAST KE AddressModel
            return EditAddressScreen(addressData: addressData);
          },
        ),

        //halaman layanan
        //layanan tersedia
        GoRoute(
          path: '/profile/layanan',
          name: 'layanan',
          builder: (context, state) =>
              const ServiceScreen(screenType: 'layanan'),
        ),

        GoRoute(
          path: '/profile/layanan/detail',
          name: 'layanan-detail',
          builder: (context, state) {
            final service = state.extra as Map<String, dynamic>;
            return ServiceDetailScreen(service: service, isMethod: false);
          },
        ),

        //metode layanan
        GoRoute(
          path: '/profile/metode-layanan',
          name: 'metode-layanan',
          builder: (context, state) => const MetodeLayananScreen(),
        ),

        GoRoute(
          path: '/profile/metode-layanan/detail',
          name: 'metode-layanan-detail',
          builder: (context, state) {
            final metode = state.extra as Map<String, dynamic>;
            return MetodeDetailScreen(metode: metode);
          },
        ),

        //Pusat bantuan
        // Tambahkan di dalam routes:
        GoRoute(
          path: '/profile/help',
          name: 'help',
          builder: (context, state) => const HelpScreen(),
        ),

        // Pet //
        // Pets List (Data Hewan)
        GoRoute(
          path: '/pets',
          name: 'pets',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: PetsPage()),
        ),

        //add pet
        GoRoute(
          path: '/add-pet',
          pageBuilder: (context, state) => MaterialPage(
            child: AddPetPage(), // Pastikan import AddPetPage
          ),
        ),

        //edit page
        GoRoute(
          path: '/edit-pet/:id',
          builder: (context, state) {
            final petData = state.extra;

            if (petData == null) {
              // Jika tidak ada data, kembali ke halaman pets
              context.go('/pets');
              return const SizedBox.shrink();
            }

            // Support baik PetModel maupun Map untuk backward compatibility
            if (petData is PetModel) {
              return EditPetPage(petData: petData);
            } else if (petData is Map<String, dynamic>) {
              // Convert Map ke PetModel
              final pet = PetModel.fromJson(petData);
              return EditPetPage(petData: pet);
            }

            context.go('/pets');
            return const SizedBox.shrink();
          },
        ),

        //detail page pet
        GoRoute(
          path: '/pet-detail/:id',
          builder: (context, state) {
            // Ambil data dari extra
            final petData = state.extra;

            if (petData == null) {
              // Jika tidak ada data, kembali ke halaman pets
              context.go('/pets');
              return const SizedBox.shrink();
            }

            // Support baik PetModel maupun Map untuk backward compatibility
            if (petData is PetModel) {
              return PetDetailScreen(petData: petData);
            } else if (petData is Map<String, dynamic>) {
              // Convert Map ke PetModel
              final pet = PetModel.fromJson(petData);
              return PetDetailScreen(petData: pet);
            }

            context.go('/pets');
            return const SizedBox.shrink();
          },
        ),

        //medical page pet
        GoRoute(
          path: '/medical-notes',
          builder: (context, state) {
            final petData = state.extra as Map<String, dynamic>?;

            if (petData == null) {
              context.go('/pets');
              return const SizedBox.shrink();
            }

            return MedicalNotesDetailScreen(petData: petData);
          },
        ),

        //Bagian add mecidal record
        GoRoute(
          path: '/add-medical-record',
          builder: (context, state) {
            final petData = state.extra as Map<String, dynamic>?;

            if (petData == null) {
              context.go('/pets');
              return const SizedBox.shrink();
            }

            return AddMedicalRecordScreen(petData: petData);
          },
        ),

        //Booking
        //halaman awal booking
        GoRoute(
          path: '/bookings',
          name: 'bookings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: BookingsPage()),
        ),

        //Halaman booking salon
        GoRoute(
          path: '/booking-new',
          builder: (context, state) => BookingNewScreen(
            extraData: state.extra as Map<String, dynamic>?,
          ),
        ),

        // Di file routing utama
        GoRoute(
          path: '/booking-quick', // Route untuk quick booking
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return BookingNewScreen(
              extraData: extra,
              isQuickBooking: true, // Tambah parameter ini
            );
          },
        ),

        //booking detailnya
        GoRoute(
          path: '/booking-detail', // ✅ TANPA :bookingId
          name: 'booking-detail',
          pageBuilder: (context, state) {
            print('✅ Route /booking-detail diakses');

            final extra = state.extra as Map<String, dynamic>?;

            if (extra == null) {
              print('⚠️ Tidak ada extra data, redirect ke bookings');
              return NoTransitionPage(
                child: BookingsPage(),
              );
            }

            print('📦 Extra data diterima: ${extra['id']}');

            return MaterialPage(
              child: BookingDetailScreen(bookingData: extra),
            );
          },
        ),

        //notifikasi
        GoRoute(
            path: '/notification',
            name: 'notification',
            pageBuilder: (context, state) =>
                NoTransitionPage(child: NotificationScreen()))
      ],

      //error page
      errorBuilder: (context, state) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.error}'),
                  ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Go to login'),
                  )
                ],
              ),
            ),
          ));
}
