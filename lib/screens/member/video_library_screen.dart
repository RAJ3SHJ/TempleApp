import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class VideoLibraryScreen extends StatefulWidget {
  const VideoLibraryScreen({super.key});

  @override
  State<VideoLibraryScreen> createState() => _VideoLibraryScreenState();
}

class Video {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String date;
  final String category;
  final String type; // 'uploaded' or 'youtube'
  final String youtubeId;
  final int views;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.date,
    required this.category,
    required this.type,
    required this.youtubeId,
    required this.views,
  });
}

class _VideoLibraryScreenState extends State<VideoLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All', 'Sermon', 'Study', 'Worship', 'Youth', 'Special'
  ];

  final List<Video> _videos = [
    Video(
      id: '1',
      title: 'Sunday Service — May 10, 2026',
      description: 'Join us for our weekly Sunday worship service as we continue our series on the Gospel of John.',
      duration: '45 min',
      date: '10 May 2026',
      category: 'Sermon',
      type: 'youtube',
      youtubeId: 'dQw4w9WgXcQ',
      views: 1240,
    ),
    Video(
      id: '2',
      title: 'Bible Study — Book of John Ch. 3',
      description: 'An in-depth study of John Chapter 3, exploring the conversation between Jesus and Nicodemus.',
      duration: '62 min',
      date: '7 May 2026',
      category: 'Study',
      type: 'youtube',
      youtubeId: 'dQw4w9WgXcQ',
      views: 890,
    ),
    Video(
      id: '3',
      title: 'Easter Special Worship 2026',
      description: 'A special worship service celebrating the resurrection of our Lord Jesus Christ.',
      duration: '30 min',
      date: '20 Apr 2026',
      category: 'Worship',
      type: 'uploaded',
      youtubeId: '',
      views: 3400,
    ),
    Video(
      id: '4',
      title: 'Youth Fellowship — April 2026',
      description: 'Monthly youth fellowship meeting with praise, worship and the Word.',
      duration: '55 min',
      date: '15 Apr 2026',
      category: 'Youth',
      type: 'youtube',
      youtubeId: 'dQw4w9WgXcQ',
      views: 560,
    ),
    Video(
      id: '5',
      title: 'Good Friday Service 2026',
      description: 'Remembering the sacrifice of Jesus Christ on the cross.',
      duration: '75 min',
      date: '18 Apr 2026',
      category: 'Special',
      type: 'uploaded',
      youtubeId: '',
      views: 2100,
    ),
    Video(
      id: '6',
      title: 'Sunday Service — May 3, 2026',
      description: 'Weekly Sunday worship service — first Sunday of May 2026.',
      duration: '48 min',
      date: '3 May 2026',
      category: 'Sermon',
      type: 'youtube',
      youtubeId: 'dQw4w9WgXcQ',
      views: 1890,
    ),
  ];

  List<Video> get _filteredVideos {
    return _videos.where((v) {
      final matchesCategory = _selectedCategory == 'All' || v.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          v.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Sermon': return AppTheme.navy;
      case 'Study': return AppTheme.gold;
      case 'Worship': return const Color(0xFF7C3AED);
      case 'Youth': return AppTheme.success;
      case 'Special': return const Color(0xFFDC2626);
      default: return AppTheme.navy;
    }
  }

  Color _getCategoryBgColor(String category) {
    switch (category) {
      case 'Sermon': return AppTheme.navyLight;
      case 'Study': return const Color(0xFFFEF3C7);
      case 'Worship': return const Color(0xFFEDE9FE);
      case 'Youth': return AppTheme.successLight;
      case 'Special': return AppTheme.errorLight;
      default: return AppTheme.navyLight;
    }
  }

  String _formatViews(int views) {
    if (views >= 1000) return '${(views / 1000).toStringAsFixed(1)}K views';
    return '$views views';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildCategoryFilter(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllVideos(),
                _buildAllVideos(youtubeOnly: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppTheme.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.white, size: 20),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          const Text(
            'Video Library',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppTheme.navy,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search videos...',
          hintStyle: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppTheme.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          filled: true,
          fillColor: AppTheme.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.navy : AppTheme.navyLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppTheme.white : AppTheme.navy,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.navy,
        indicatorWeight: 3,
        labelColor: AppTheme.navy,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        tabs: const [
          Tab(text: 'All Videos'),
          Tab(text: 'YouTube'),
        ],
      ),
    );
  }

  Widget _buildAllVideos({bool youtubeOnly = false}) {
    final videos = youtubeOnly
        ? _filteredVideos.where((v) => v.type == 'youtube').toList()
        : _filteredVideos;

    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, size: 64,
                color: AppTheme.textSecondary.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ? 'No videos found for "$_searchQuery"' : 'No videos available',
              style: TextStyle(fontSize: 15, color: AppTheme.textSecondary.withOpacity(0.6)),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: videos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) => _buildVideoCard(videos[index]),
    );
  }

  Widget _buildVideoCard(Video video) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: video.type == 'youtube' ? AppTheme.navy : AppTheme.navyMid,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow_rounded,
                              size: 32, color: AppTheme.white),
                        ),
                      ],
                    ),
                  ),
                  // Duration badge
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        video.duration,
                        style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  // YouTube badge
                  if (video.type == 'youtube')
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF0000),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow_rounded, size: 12, color: Colors.white),
                            SizedBox(width: 3),
                            Text('YouTube', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _getCategoryBgColor(video.category),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          video.category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getCategoryColor(video.category),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatViews(video.views),
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    video.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    video.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 12, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(video.date, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Video Player Screen
class VideoPlayerScreen extends StatelessWidget {
  final Video video;
  const VideoPlayerScreen({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Video Player Area
          Container(
            color: Colors.black,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Back button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  // Player placeholder
                  Container(
                    height: 220,
                    color: Colors.black87,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow_rounded, size: 40, color: Colors.white),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            video.type == 'youtube' ? 'YouTube Video' : 'Church Video',
                            style: const TextStyle(fontSize: 13, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Video Details
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & views
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.navyLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          video.category,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.navy),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.visibility_outlined, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${video.views} views',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Title
                  Text(
                    video.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 8),

                  // Meta
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 13, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(video.date, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time_rounded, size: 13, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(video.duration, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.border),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'About this video',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.navy),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    video.description,
                    style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.7),
                  ),
                  const SizedBox(height: 20),

                  // Church info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.navyLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.church_rounded, size: 20, color: AppTheme.navy),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Grace Bible Church',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.navy)),
                            Text('123, Mission Road, Hyderabad',
                                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}