import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../constants/strings.dart';
import '../controllers/diary_controller.dart';
import '../services/admob_service.dart';
import '../services/auth_service.dart';
import 'historial_screen.dart';
import 'login_screen.dart';

class DiarioScreen extends StatefulWidget {
  const DiarioScreen({super.key, this.enableAds = true});

  final bool enableAds;

  @override
  State<DiarioScreen> createState() => _DiarioScreenState();
}

class _DiarioScreenState extends State<DiarioScreen> {
  final TextEditingController _controller = TextEditingController();

  bool _estaCargando = false;
  List<String> _emocionesDetectadas = [];
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _bannerListo = false;
  int _guardadosExitosos = 0;

  @override
  void initState() {
    super.initState();
    if (widget.enableAds) {
      _cargarBanner();
      _cargarInterstitial();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  Future<void> _cerrarSesion() async {
    await context.read<AuthService>().signOut();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _cargarBanner() {
    if (!AdMobService.isSupported) return;

    final banner = BannerAd(
      adUnitId: AdMobService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _bannerListo = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          setState(() => _bannerListo = false);
        },
      ),
    );

    banner.load();
  }

  void _cargarInterstitial() {
    if (!AdMobService.isSupported) return;

    InterstitialAd.load(
      adUnitId: AdMobService.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  void _mostrarInterstitialSiCorresponde() {
    if (!AdMobService.isSupported) return;

    _guardadosExitosos++;
    if (_guardadosExitosos % 3 != 0) return;

    final ad = _interstitialAd;
    if (ad == null) {
      _cargarInterstitial();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _cargarInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitialAd = null;
        _cargarInterstitial();
      },
    );

    ad.show();
    _interstitialAd = null;
  }

  Future<void> _analizarYGuardar() async {
    final textoBusqueda = _controller.text.trim();
    if (textoBusqueda.isEmpty) return;

    setState(() => _estaCargando = true);

    try {
      final listaEmociones = await context.read<DiaryController>().analizarYGuardar(textoBusqueda);

      if (!mounted) return;

      setState(() {
        _emocionesDetectadas = listaEmociones;
        _estaCargando = false;
        _controller.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.diarySaved),
          backgroundColor: Colors.deepPurple,
        ),
      );

      if (widget.enableAds) {
        _mostrarInterstitialSiCorresponde();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _estaCargando = false);

      final message = e.toString();
      final uiMessage = message.contains('permission') || message.contains('sesión')
          ? AppStrings.diaryNeedLogin
          : message.replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(uiMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.diaryTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: AppStrings.logout,
            onPressed: _cerrarSesion,
          ),
          IconButton(
            icon: const Icon(Icons.history_edu_rounded),
            tooltip: AppStrings.viewHistory,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistorialScreen()),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.auto_awesome_outlined, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 16),
            const Text(
              AppStrings.diaryPrompt,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: AppStrings.diaryHint,
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Colors.grey.withValues(alpha: 0.05),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _estaCargando ? null : _analizarYGuardar,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              child: _estaCargando
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      AppStrings.diaryAnalyze,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(height: 32),
            if (_emocionesDetectadas.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                AppStrings.diaryAnalysisTitle,
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: _emocionesDetectadas
                    .map(
                      (e) => Chip(
                        label: Text(e, style: const TextStyle(color: Colors.deepPurple)),
                        backgroundColor: Colors.deepPurple.withValues(alpha: 0.1),
                        side: const BorderSide(color: Colors.deepPurple, width: 0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    )
                    .toList(),
              ),
            ]
          ],
        ),
      ),
      bottomNavigationBar: widget.enableAds && _bannerListo && _bannerAd != null
          ? SafeArea(
              child: SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                width: _bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            )
          : null,
    );
  }
}

