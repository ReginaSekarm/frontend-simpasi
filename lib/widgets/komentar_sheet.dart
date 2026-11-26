import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../services/comment_service.dart';
import '../services/user_service.dart';

class GoogleFonts {
  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }
}

// ================= MODEL KOMENTAR =================
class KomentarItem {
  final int? id;
  final int? userId;
  final int? parentCommentId;
  final String nama;
  final String? waktu;
  final DateTime? postedAt;
  final int? ageSeconds;
  String teks;
  int replyCount;
  bool repliesLoaded;
  final List<KomentarItem> balasan;

  KomentarItem({
    this.id,
    this.userId,
    this.parentCommentId,
    required this.nama,
    this.waktu,
    this.postedAt,
    this.ageSeconds,
    required this.teks,
    this.replyCount = 0,
    this.repliesLoaded = false,
    List<KomentarItem>? balasan,
  }) : balasan = balasan ?? [];

  bool get adaBalasan => replyCount > 0 || balasan.isNotEmpty;

  static String formatWaktu(DateTime? dt, int? ageSeconds) {
    int diffSec;
    if (ageSeconds != null && ageSeconds >= 0) {
      diffSec = ageSeconds;
    } else if (dt != null) {
      diffSec = DateTime.now().difference(dt).inSeconds;
      if (diffSec < 0) diffSec = 0;
    } else {
      return 'Baru saja';
    }

    if (diffSec < 60) return 'Baru saja';
    final minutes = diffSec ~/ 60;
    if (minutes < 60) return '$minutes mnt';
    final hours = minutes ~/ 60;
    if (hours < 24) return '$hours jam';
    final days = hours ~/ 24;
    return '$days hari';
  }
}

// ================= BOTTOM SHEET KOMENTAR =================
class KomentarSheet extends StatefulWidget {
  final int? recipeId;
  final String recipeTitle;
  final String? currentUserName;

  const KomentarSheet({
    super.key,
    this.recipeId,
    required this.recipeTitle,
    this.currentUserName,
  });

  @override
  State<KomentarSheet> createState() => _KomentarSheetState();
}

class _KomentarSheetState extends State<KomentarSheet> {
  static const Color primaryRed  = Color(0xFFD45060);
  static const Color textBlack   = Color(0xFF000000);
  static const Color textGrey    = Color(0xFF8F8F8F);
  static const Color dividerGrey = Color(0xFFD9D9D9);
  static const Color blueTag     = Color(0xFF006199);

  String _myName = '';

  final List<String> _knownNames = ['Siti Amaliah', 'Aisyah', 'Uni', 'Wowo'];

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  final Set<KomentarItem> _expanded = {};
  KomentarItem? _replyTo;
  KomentarItem? _replyRoot;

  // Kosong saat belum ada komentar
  final List<KomentarItem> _komentar = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _myName = (widget.currentUserName ?? '').trim();
    if (_myName.isNotEmpty && !_knownNames.contains(_myName)) {
      _knownNames.add(_myName);
    }
    _initData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    if (_myName.isEmpty) {
      final prof = await UserService.getProfile();
      if (mounted && prof.profile != null && prof.profile!.fullName.trim().isNotEmpty) {
        setState(() {
          _myName = prof.profile!.fullName.trim();
          if (!_knownNames.contains(_myName)) {
            _knownNames.add(_myName);
          }
        });
      }
    }
    await _loadComments();
  }

  Future<void> _loadComments() async {
    final rId = widget.recipeId;
    if (rId == null) {
      setState(() {
        _komentar.clear();
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);
    final res = await CommentService.getComments(rId);
    if (!mounted) return;

    final loaded = res.comments.map((t) {
      if (!_knownNames.contains(t.userName)) {
        _knownNames.add(t.userName);
      }
      return KomentarItem(
        id: t.id,
        userId: t.userId,
        nama: t.userName,
        waktu: KomentarItem.formatWaktu(t.createdAt, t.ageSeconds),
        postedAt: t.createdAt,
        ageSeconds: t.ageSeconds,
        teks: t.content,
        replyCount: t.replyCount,
        repliesLoaded: false,
      );
    }).toList();

    setState(() {
      _komentar
        ..clear()
        ..addAll(loaded);
      _isLoading = false;
    });

    if (res.error != null) {
      _showSnack(res.error!);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
      );
  }

  KomentarItem? _findRootFor(KomentarItem target) {
    for (final root in _komentar) {
      if (root == target) return root;
      if (root.balasan.contains(target)) return root;
      for (final sub in root.balasan) {
        if (sub.balasan.contains(target)) return root;
      }
    }
    return null;
  }

  void _handleReply(KomentarItem target) {
    final root = _findRootFor(target) ?? target;
    setState(() {
      _replyTo = target;
      _replyRoot = root;
      _controller.text = '@${target.nama} ';
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
    _focusNode.requestFocus();
  }

  Future<void> _kirim() async {
    if (_isSubmitting) return;
    final t = _controller.text.trim();
    if (t.isEmpty) return;

    final senderName = _myName.isNotEmpty ? _myName : 'Anda';
    final target = _replyTo;
    final root = _replyRoot ?? (target != null ? _findRootFor(target) : null);

    // Mode lokal jika recipeId belum tersedia
    if (widget.recipeId == null) {
      setState(() {
        final newKomentar = KomentarItem(
          nama: senderName,
          waktu: 'Baru saja',
          postedAt: DateTime.now(),
          teks: t,
        );

        if (target != null) {
          final container = root ?? target;
          container.balasan.add(newKomentar);
          container.replyCount = container.balasan.length;
          container.repliesLoaded = true;
          _expanded.add(container);
        } else {
          _komentar.insert(0, newKomentar);
        }

        _controller.clear();
        _replyTo = null;
        _replyRoot = null;
      });
      FocusScope.of(context).unfocus();
      return;
    }

    setState(() => _isSubmitting = true);

    if (target != null) {
      // Backend membatasi balasan 1 tingkat ke komentar utama (parentCommentId == null)
      final parentId = root?.id ?? target.id;
      if (parentId == null) {
        setState(() => _isSubmitting = false);
        _showSnack('ID komentar induk tidak ditemukan.');
        return;
      }

      final res = await CommentService.replyComment(
        commentId: parentId,
        content: t,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (!res.success) {
        _showSnack(res.error ?? 'Gagal mengirim balasan.');
        return;
      }

      _controller.clear();
      _replyTo = null;
      _replyRoot = null;
      FocusScope.of(context).unfocus();

      final targetRoot = root ?? target;
      final freshReplies = await CommentService.getReplies(parentId);
      if (!mounted) return;
      setState(() {
        targetRoot.balasan
          ..clear()
          ..addAll(
            freshReplies.map((r) {
              if (!_knownNames.contains(r.userName)) {
                _knownNames.add(r.userName);
              }
              return KomentarItem(
                id: r.id,
                userId: r.userId,
                parentCommentId: parentId,
                nama: r.userName,
                waktu: KomentarItem.formatWaktu(r.createdAt, r.ageSeconds),
                postedAt: r.createdAt,
                ageSeconds: r.ageSeconds,
                teks: r.content,
              );
            }),
          );
        targetRoot.replyCount = targetRoot.balasan.length;
        targetRoot.repliesLoaded = true;
        _expanded.add(targetRoot);
      });
    } else {
      final res = await CommentService.createComment(
        recipeId: widget.recipeId!,
        content: t,
      );
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (!res.success) {
        _showSnack(res.error ?? 'Gagal menambahkan komentar.');
        return;
      }

      _controller.clear();
      _replyTo = null;
      _replyRoot = null;
      FocusScope.of(context).unfocus();
      await _loadComments();
    }
  }

  Future<void> _toggleExpand(KomentarItem item) async {
    final willExpand = !_expanded.contains(item);
    setState(() {
      if (willExpand) {
        _expanded.add(item);
      } else {
        _expanded.remove(item);
      }
    });

    if (willExpand && item.id != null && !item.repliesLoaded) {
      final fetched = await CommentService.getReplies(item.id!);
      if (!mounted) return;
      setState(() {
        item.balasan
          ..clear()
          ..addAll(
            fetched.map((r) {
              if (!_knownNames.contains(r.userName)) {
                _knownNames.add(r.userName);
              }
              return KomentarItem(
                id: r.id,
                userId: r.userId,
                parentCommentId: item.id,
                nama: r.userName,
                waktu: KomentarItem.formatWaktu(r.createdAt, r.ageSeconds),
                postedAt: r.createdAt,
                ageSeconds: r.ageSeconds,
                teks: r.content,
              );
            }),
          );
        item.repliesLoaded = true;
        if (item.balasan.isNotEmpty) {
          item.replyCount = item.balasan.length;
        }
      });
    }
  }

  bool _isOwnedByCurrentUser(KomentarItem k) {
    if (_myName.isEmpty) return false;
    return k.nama.trim().toLowerCase() == _myName.trim().toLowerCase();
  }

  bool _canEditComment(KomentarItem k) {
    if (!_isOwnedByCurrentUser(k)) return false;
    if (k.ageSeconds != null) {
      return k.ageSeconds! <= 24 * 60 * 60;
    }
    if (k.postedAt != null) {
      return DateTime.now().difference(k.postedAt!).inHours < 24;
    }
    return true;
  }

  // POPUP HAPUS KOMENTAR (GAYA INSTAGRAM: BLUR + KOMENTAR MENONJOL + MENU HAPUS)
  void _showDeletePopup(KomentarItem k, BuildContext commentContext) {
    final RenderBox box = commentContext.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);
    final Size screen = MediaQuery.of(context).size;
    final double bottomSafe = MediaQuery.of(context).padding.bottom;

    final bool canEdit = _canEditComment(k);

    const double pad = 8;
    final double width =
        (box.size.width + pad * 2).clamp(0.0, screen.width).toDouble();
    final double left =
        (position.dx - pad).clamp(0.0, screen.width - width).toDouble();

    final double maxTop = screen.height - bottomSafe - 190;
    double top = position.dy - pad;
    if (top > maxTop) top = maxTop;
    if (top < 0) top = 0;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Tutup',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.pop(ctx),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(color: const Color(0x73000000)),
                  ),
                ),
              ),
              Positioned(
                left: left,
                top: top,
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(pad),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                              image: k.nama == 'Siti Amaliah'
                                  ? const DecorationImage(
                                      image: AssetImage(
                                          'assets/images/profil-kader.png'),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: k.nama != 'Siti Amaliah'
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 22,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      k.nama,
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: textBlack,
                                        height: 18 / 15,
                                      ),
                                    ),
                                    if (k.waktu != null) ...[
                                      const SizedBox(width: 10),
                                      Text(
                                        k.waktu!,
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: textGrey,
                                          height: 12 / 10,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 5),
                                _buildCommentText(k.teks),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(
                                      'Balas',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: textGrey,
                                        height: 15 / 12,
                                      ),
                                    ),
                                    if (canEdit) ...[
                                      const SizedBox(width: 15),
                                      Text(
                                        'Edit',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: textGrey,
                                          height: 15 / 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          width: 170,
                          height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0x33D9D9D9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border(
                              top: BorderSide(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 1.0,
                              ),
                              bottom: BorderSide(
                                color: Colors.white.withValues(alpha: 0.6),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: InkWell(
                            onTap: () async {
                              Navigator.pop(ctx);
                              if (k.id != null) {
                                final res =
                                    await CommentService.deleteComment(k.id!);
                                if (!mounted) return;
                                if (!res.success) {
                                  _showSnack(
                                      res.error ?? 'Gagal menghapus komentar.');
                                  return;
                                }
                              }
                              if (!mounted) return;
                              setState(() {
                                _hapusKomentarDariList(k);
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/trash-fill.svg',
                                    width: 22,
                                    height: 22,
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFFFF0020),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Text(
                                    'Hapus',
                                    maxLines: 1,
                                    softWrap: false,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFFFF0020),
                                      height: 19 / 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  void _hapusKomentarDariList(KomentarItem target) {
    _komentar.removeWhere((element) => element == target);
    for (var item in _komentar) {
      final before = item.balasan.length;
      item.balasan.removeWhere((element) => element == target);
      if (item.balasan.length != before) {
        item.replyCount = item.balasan.length;
      }
      for (var sub in item.balasan) {
        sub.balasan.removeWhere((element) => element == target);
      }
    }
    _expanded.remove(target);
  }

  void _editKomentar(KomentarItem k) {
    final textController = TextEditingController(text: k.teks);
    final FocusNode editFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      editFocusNode.requestFocus();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mengedit komentar',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: textGrey,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.close, color: textGrey, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        image: k.nama == 'Siti Amaliah'
                            ? const DecorationImage(
                                image:
                                    AssetImage('assets/images/foto_siti.png'),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: k.nama != 'Siti Amaliah'
                          ? const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 22,
                            )
                          : null,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: textController,
                          focusNode: editFocusNode,
                          maxLines: null,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: textBlack,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      final updated = textController.text.trim();
                      if (updated.isEmpty) return;

                      Navigator.pop(ctx);
                      if (k.id != null) {
                        final res = await CommentService.updateComment(
                          commentId: k.id!,
                          content: updated,
                        );
                        if (!mounted) return;
                        if (!res.success) {
                          _showSnack(
                              res.error ?? 'Gagal memperbarui komentar.');
                          return;
                        }
                      }
                      if (!mounted) return;
                      setState(() {
                        k.teks = updated;
                      });
                    },
                    child: Text(
                      'Simpan',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryRed,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      editFocusNode.dispose();
      textController.dispose();
    });
  }

  Widget _buildCommentText(String text) {
    if (text.startsWith('@')) {
      for (String name in _knownNames) {
        final tagWithSpace = '@$name ';

        if (text.startsWith(tagWithSpace)) {
          final tag = tagWithSpace.trim();
          final rest = text.substring(tagWithSpace.length);

          return RichText(
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: textBlack,
                height: 15 / 12,
              ),
              children: [
                TextSpan(
                  text: '$tag ',
                  style: const TextStyle(color: blueTag),
                ),
                TextSpan(text: rest),
              ],
            ),
          );
        }
      }
    }

    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textBlack,
        height: 15 / 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.85;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxH),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(27, 14, 27, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: dividerGrey,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Komentar (${_komentar.length})',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textBlack,
                    height: 18 / 15,
                  ),
                ),
                const SizedBox(height: 19),

                Flexible(
                  child: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 28),
                          child: Center(
                            child: CircularProgressIndicator(color: primaryRed),
                          ),
                        )
                      : _komentar.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 28),
                              child: Center(
                                child: Text(
                                  'Belum ada komentar',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: textGrey,
                                  ),
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (int i = 0; i < _komentar.length; i++) ...[
                                    if (i > 0) const SizedBox(height: 19),
                                    _buildComment(_komentar[i]),
                                  ],
                                ],
                              ),
                            ),
                ),

                const SizedBox(height: 44),

                _buildInput(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComment(KomentarItem k) {
    final isMe = _isOwnedByCurrentUser(k);
    final isExpanded = _expanded.contains(k);
    final canEdit = _canEditComment(k);
    final displayReplyCount =
        k.balasan.isNotEmpty ? k.balasan.length : k.replyCount;

    return Builder(
      builder: (commentContext) {
        return GestureDetector(
          onLongPress: isMe ? () => _showDeletePopup(k, commentContext) : null,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                  image: k.nama == 'Siti Amaliah'
                      ? const DecorationImage(
                          image: AssetImage('assets/images/profil-kader.png'),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: k.nama != 'Siti Amaliah'
                    ? const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 22,
                      )
                    : null,
              ),
              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          k.nama,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: textBlack,
                            height: 18 / 15,
                          ),
                        ),
                        if (k.waktu != null) ...[
                          const SizedBox(width: 10),
                          Text(
                            k.waktu!,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: textGrey,
                              height: 12 / 10,
                            ),
                          ),
                        ],
                        if (k.nama == 'Siti Amaliah') ...[
                          const SizedBox(width: 3),
                          SizedBox(
                            width: 6,
                            height: 6,
                            child: Center(
                              child: Container(
                                width: 2.5,
                                height: 2.5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF797777),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Pembuat',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: textGrey,
                              height: 12 / 10,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 5),

                    _buildCommentText(k.teks),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _handleReply(k),
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              'Balas',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: textGrey,
                                height: 15 / 12,
                              ),
                            ),
                          ),
                        ),
                        if (canEdit) ...[
                          const SizedBox(width: 15),
                          GestureDetector(
                            onTap: () => _editKomentar(k),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                'Edit',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textGrey,
                                  height: 15 / 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (displayReplyCount > 0) ...[
                          const SizedBox(width: 27),
                          GestureDetector(
                            onTap: () => _toggleExpand(k),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                isExpanded
                                    ? 'Sembunyikan balasan'
                                    : 'Lihat balasan ($displayReplyCount)',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textGrey,
                                  height: 15 / 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (k.balasan.isNotEmpty && isExpanded) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.only(left: 12),
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(color: dividerGrey, width: 2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < k.balasan.length; i++) ...[
                              if (i > 0) const SizedBox(height: 14),
                              _buildComment(k.balasan[i]),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInput() {
    return Container(
      height: 52,
      padding: const EdgeInsets.only(left: 24, right: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: const Color(0xFFD9D9D9),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _kirim(),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: textBlack,
                height: 19 / 16,
              ),
              decoration: InputDecoration(
                hintText: 'Tulis komentar...',
                hintStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8E8E8E),
                  height: 19 / 16,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isSubmitting ? null : _kirim,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryRed,
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/images/paper-plane-outline.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        primaryRed,
                        BlendMode.srcIn,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}