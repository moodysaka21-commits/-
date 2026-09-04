import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  runApp(const AzkarApp());
}

class AzkarApp extends StatelessWidget {
  const AzkarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'زاد الذاكرين',
      theme: ThemeData(
        fontFamily: 'sans-serif',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4332),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF081C15),
      ),
      home: const CategoriesScreen(),
    );
  }
}

// ------------------- قاعدة البيانات (SQLite) -------------------

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('azkar_database_v2.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        icon TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE azkar (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoryId INTEGER NOT NULL,
        text TEXT NOT NULL,
        benefit TEXT NOT NULL,
        targetCount INTEGER NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    await _insertInitialData(db);
  }

  Future<void> _insertInitialData(Database db) async {
    int cat1 = await db.insert('categories', {
      'name': 'أذكار الاستغفار والتوبة',
      'description': 'ممحاة الذنوب وانشراح الصدر والسكينة',
      'icon': '🤲'
    });
    int cat2 = await db.insert('categories', {
      'name': 'أذكار الشكر والثناء',
      'description': 'حفظ النعم وزيادتها والاعتراف بالفضل',
      'icon': '✨'
    });
    int cat3 = await db.insert('categories', {
      'name': 'أفضل وأعظم الأذكار',
      'description': 'أثقل الكلمات في الميزان وأحبها إلى الرحمن',
      'icon': '💎'
    });

    final batch = db.batch();

    // 1. أذكار الاستغفار والتوبة (+20)
    final List<Map<String, dynamic>> istighfar = [
      {'text': 'أستغفر الله وأتوب إليه', 'benefit': 'ممحاة للذنوب وجالبة للرزق والبركة والولد.', 'target': 100},
      {'text': 'اللهم أنت ربي لا إله إلا أنت، خلقتني وأنا عبدك، وأنا على عهدك ووعدك ما استطعت، أعوذ بك من شر ما صنعت، أبوء لك بنعمتك عليّ، وأبوء بذنبي فاغفر لي فإنه لا يغفر الذنوب إلا أنت', 'benefit': 'سيد الاستغفار؛ من قاله موقناً به ومات دخل الجنة.', 'target': 3},
      {'text': 'أستغفر الله العظيم الذي لا إله إلا هو الحي القيوم وأتوب إليه', 'benefit': 'غُفرت ذنوبه وإن كان قد فرّ من الزحف.', 'target': 3},
      {'text': 'رب اغفر لي وتب عليّ إنك أنت التواب الرحيم', 'benefit': 'كان يُعد للنبي ﷺ في المجلس الواحد مائة مرة.', 'target': 100},
      {'text': 'اللهم إني ظلمت نفسي ظلماً كثيراً، ولا يغفر الذنوب إلا أنت، فاغفر لي مغفرة من عندك وارحمني إنك أنت الغفور الرحيم', 'benefit': 'دعاء علّمه النبي ﷺ لأبي بكر ليدعو به في صلاته.', 'target': 3},
      {'text': 'سبحانك اللهم وبحمدك، أشهد أن لا إله إلا أنت، أستغفرك وأتوب إليك', 'benefit': 'كفارة المجلس؛ تمحو ما كان فيه من لغو.', 'target': 1},
      {'text': 'اللهم اغفر لي خطيئتي وجهلي، وإسرافي في أمري، وما أنت أعلم به مني', 'benefit': 'استغفار شامل للخطأ والعمد والجهل.', 'target': 3},
      {'text': 'اللهم اغفر لي جِدّي وهزلي، وخطئي وعمدي، وكل ذلك عندي', 'benefit': 'دعاء نبوي للاعتراف بالنقص والتقصير.', 'target': 3},
      {'text': 'اللهم اغفر لي ما قدمت وما أخرت، وما أسررت وما أعلنت، وما أسرفت، وما أنت أعلم به مني', 'benefit': 'من جوامع دعاء الاستغفار في ختام الصلاة.', 'target': 1},
      {'text': 'أستغفر الله', 'benefit': 'يُفتتح به الذكر دبر الصلوات المكتوبة لتكميل النقص.', 'target': 3},
      {'text': 'رب إني لما أنزلت إليّ من خير فقير', 'benefit': 'دعاء موسى عليه السلام لجلب الفرج وتيسير الأمور.', 'target': 7},
      {'text': 'ربنا إننا آمنا فاغفر لنا ذنوبنا وقنا عذاب النار', 'benefit': 'وصف عباد الله المتقين المستوجبين للرحمة.', 'target': 3},
      {'text': 'ربنا ظلمنا أنفسنا وإن لم تغفر لنا وترحمنا لنكونن من الخاسرين', 'benefit': 'دعاء آدم وحواء عليهما السلام لطلب العفو والمغفرة.', 'target': 3},
      {'text': 'اللهم باعد بيني وبين خطاياي كما باعدت بين المشرق والمغرب', 'benefit': 'دعاء الاستفتاح في الصلاة لتطهير الباطن.', 'target': 1},
      {'text': 'اللهم نقني من الخطايا كما ينقى الثوب الأبيض من الدنس', 'benefit': 'سؤال النقاء والصفاء من آثار المعاصي.', 'target': 1},
      {'text': 'اللهم اغسل خطاياي بالماء والثلج والبرد', 'benefit': 'إطفاء حرارة المعاصي والذنوب.', 'target': 1},
      {'text': 'رب اغفر وارحم وأنت خير الراحمين', 'benefit': 'طلب أوسع أبواب الرحمة والمغفرة الربانية.', 'target': 10},
      {'text': 'اللهم إني أستغفرك من كل ذنب تبت إليك منه ثم عدت فيه', 'benefit': 'تجديد عهد التوبة وإخلاص النية.', 'target': 7},
      {'text': 'أستغفر الله عدد ما خلق، أستغفر الله ملء ما خلق', 'benefit': 'استغفار مضاعف الأجر بعدد الكائنات والمخلوقات.', 'target': 10},
      {'text': 'ربنا اغفر لنا ولإخواننا الذين سبقونا بالإيمان', 'benefit': 'طهور القلب وسلامة الصدر تجاه المسلمين.', 'target': 3},
      {'text': 'أستغفر الله بعدد ذنوبي حتى تُغفر', 'benefit': 'إلحاح وتضرع بطلب العفو والمغفرة الشاملة.', 'target': 33},
    ];

    for (var item in istighfar) {
      batch.insert('azkar', {
        'categoryId': cat1,
        'text': item['text'],
        'benefit': item['benefit'],
        'targetCount': item['target'],
      });
    }

    // 2. أذكار الشكر والثناء (+20)
    final List<Map<String, dynamic>> shukr = [
      {'text': 'الحمد لله حمداً كثيراً طيباً مباركاً فيه', 'benefit': 'ابتدرها بضعة وثلاثون ملكاً أيهم يكتبها أولاً.', 'target': 33},
      {'text': 'اللهم ما أصبح بي من نعمة أو بأحد من خلقك فمنك وحدك لا شريك لك، فلك الحمد ولك الشكر', 'benefit': 'من قالها حين يصبح أدى شكر يومه، ومن قالها حين يمسي أدى شكر ليلته.', 'target': 1},
      {'text': 'الحمد لله الذي بنعمته تتم الصالحات', 'benefit': 'يقال عند رؤية ما يحب المرء وتيسر الأمور.', 'target': 3},
      {'text': 'الحمد لله على كل حال', 'benefit': 'يقال عند الشدائد والصبر والرضا بقضاء الله.', 'target': 3},
      {'text': 'اللهم لك الحمد ملء السماوات وملء الأرض وملء ما شئت من شيء بعد', 'benefit': 'ثناء عظيم يملأ الميزان بالأجر.', 'target': 3},
      {'text': 'اللهم أعني على ذكرك وشكرك وحسن عبادتك', 'benefit': 'وصية النبي ﷺ لمعاذ في دبر كل صلاة.', 'target': 3},
      {'text': 'الحمد لله رب العالمين', 'benefit': 'أول آية في أم الكتاب وأساس كل شكر وثناء.', 'target': 100},
      {'text': 'اللهم لك الحمد حمداً يوافي نعمك ويكافئ مزيدك', 'benefit': 'إقرار بعجز العبد عن حصر نعم المنعم.', 'target': 3},
      {'text': 'الحمد لله الذي أطعمنا وسقانا وكفانا وآوانا', 'benefit': 'يقال عند النوم شكراً على المأوى والأمن.', 'target': 1},
      {'text': 'الحمد لله الذي عافاني مما ابتلاك به وفضلني على كثير ممن خلق تفضيلاً', 'benefit': 'من قالها عند رؤية مبتلى عوفي من ذلك البلاء.', 'target': 1},
      {'text': 'اللهم لك الحمد كالذي نقول وخيراً مما نقول', 'benefit': 'إعلاء الثناء الإلهي فوق كل عبارة وبلاغة.', 'target': 3},
      {'text': 'الحمد لله الذي كفانا وأروانا غير مكفي ولا مكفور', 'benefit': 'يقال عقب الانتهاء من تناول الطعام.', 'target': 1},
      {'text': 'رب أوزعني أن أشكر نعمتك التي أنعمت عليّ وعلى والديّ', 'benefit': 'دعاء الأنبياء للثبات على الشكر والبر.', 'target': 3},
      {'text': 'الحمد لله ملء الميزان ومنتهى العلم ومبلغ الرضا', 'benefit': 'طلب بلوغ الغاية العظمى في الرضا والحمد.', 'target': 7},
      {'text': 'اللهم لك الحمد كله، ولك الملك كله، وبيدك الخير كله', 'benefit': 'توحيد وإفراد لله بالكمال والقدرة.', 'target': 3},
      {'text': 'الحمد لله عدد خلقه ورضا نفسه وزنة عرشه ومداد كلماته', 'benefit': 'حمد مضاعف يعدل ساعات من التسبيح.', 'target': 3},
      {'text': 'الحمد لله الذي أحيانا بعد ما أماتنا وإليه النشور', 'benefit': 'أول ما يستفتح به المسلم يومه عند الاستيقاظ.', 'target': 1},
      {'text': 'اللهم لك الحمد أنت نور السماوات والأرض ومن فيهن', 'benefit': 'من دعاء قيام الليل والتهجد.', 'target': 1},
      {'text': 'الحمد لله الذي هدانا لهذا وما كنا لنهتدي لولا أن هدانا الله', 'benefit': 'شكر نعمة الهداية للإسلام والإيمان.', 'target': 3},
      {'text': 'الحمد لله دائماً وأبداً', 'benefit': 'استدامة الحمد في السراء والضراء لدوام الزيادة.', 'target': 33},
      {'text': 'اللهم اجعلني لك شكاراً، لك ذكاراً', 'benefit': 'سؤال المعونة لتحقيق صدق العبودية والامتنان.', 'target': 3},
    ];

    for (var item in shukr) {
      batch.insert('azkar', {
        'categoryId': cat2,
        'text': item['text'],
        'benefit': item['benefit'],
        'targetCount': item['target'],
      });
    }

    // 3. أفضل وأعظم الأذكار (+20)
    final List<Map<String, dynamic>> afdal = [
      {'text': 'سبحان الله وبحمده، سبحان الله العظيم', 'benefit': 'كلمتان خفيفتان على اللسان، ثقيلتان في الميزان، حبيبتان إلى الرحمن.', 'target': 100},
      {'text': 'لا حول ولا قوة إلا بالله', 'benefit': 'كنز من كنوز الجنة وباب لدفع البلاء وتيسير الأمور.', 'target': 100},
      {'text': 'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير', 'benefit': 'حرز من الشيطان وتعدل عتق 10 رقاب وتمحو 100 سيئة.', 'target': 100},
      {'text': 'سبحان الله والحمد لله ولا إله إلا الله والله أكبر', 'benefit': 'أحب الكلام إلى الله وغراس الجنة.', 'target': 100},
      {'text': 'لا إله إلا أنت سبحانك إني كنت من الظالمين', 'benefit': 'دعوة ذي النون؛ ما دعا بها مكروب إلا فرج الله عنه.', 'target': 40},
      {'text': 'اللهم صلِّ وسلم على نبينا محمد', 'benefit': 'من صلى عليه واحدة صلى الله عليه بها عشراً وكُفي همه.', 'target': 100},
      {'text': 'سبحان الله وبحمده', 'benefit': 'حُطت خطاياه وإن كانت مثل زبد البحر إذا قيلت 100 مرة.', 'target': 100},
      {'text': 'يا حي يا قيوم برحمتك أستغيث، أصلح لي شأني كله ولا تكلني إلى نفسي طرفة عين', 'benefit': 'وصية نبوية للأمان وطلب المعونة الإلهية.', 'target': 3},
      {'text': 'حسبي الله لا إله إلا هو عليه توكلت وهو رب العرش العظيم', 'benefit': 'من قالها 7 مرات كفاه الله ما أهمه من أمر الدنيا والآخرة.', 'target': 7},
      {'text': 'بسم الله الذي لا يضر مع اسمه شيء في الأرض ولا في السماء وهو السميع العليم', 'benefit': 'من قالها 3 مرات لم يضره شيء حتى يصبح أو يمسي.', 'target': 3},
      {'text': 'رضيت بالله رباً، وبالإسلام ديناً، وبمحمد ﷺ نبياً ورسولاً', 'benefit': 'كان حقاً على الله أن يرضيه يوم القيامة.', 'target': 3},
      {'text': 'أعوذ بكلمات الله التامات من شر ما خلق', 'benefit': 'حفظ وقاية من الهوام والشرور ونزول المنازل.', 'target': 3},
      {'text': 'اللهم إني أسألك العافية في الدنيا والآخرة', 'benefit': 'أعظم ما يُسأل الله بعد اليقين، دعاء جامع لكل عافية.', 'target': 3},
      {'text': 'سبحان الله العظيم وبحمده', 'benefit': 'تُغرس لقائلها نخلة في الجنة.', 'target': 100},
      {'text': 'يا ذا الجلال والإكرام', 'benefit': 'حث النبي ﷺ على الإلحاح بها في الدعاء وسر الإجابة.', 'target': 33},
      {'text': 'اللهم إني أسألك علماً نافعاً، ورزقاً طيباً، وعملاً متقبلاً', 'benefit': 'دعاء نبوي كل صباح بعد صلاة الفجر.', 'target': 1},
      {'text': 'توكلت على الله ولا حول ولا قوة إلا بالله', 'benefit': 'يقال عند الخروج من المنزل: هُديت وكُفيت ووُقيت.', 'target': 1},
      {'text': 'اللهم قني عذابك يوم تبعث عبادك', 'benefit': 'يقال عند النوم ووضع اليد تحت الخد الأيمن.', 'target': 3},
      {'text': 'اللهم إنك عفو تحب العفو فاعفُ عني', 'benefit': 'الدعاء الموصى به لليلة القدر والأوقات المباركة.', 'target': 10},
      {'text': 'اللهم يا مقلب القلوب ثبت قلبي على دينك', 'benefit': 'أكثر ما كان يدعو به النبي ﷺ للثبات على الحق.', 'target': 7},
      {'text': 'سبحان الملك القدوس', 'benefit': 'يُسن قولها ثلاثاً بصوت ممتد في آخر صلاة الوتر.', 'target': 3},
    ];

    for (var item in afdal) {
      batch.insert('azkar', {
        'categoryId': cat3,
        'text': item['text'],
        'benefit': item['benefit'],
        'targetCount': item['target'],
      });
    }

    await batch.commit();
  }

  // عمليات الأقسام
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await instance.database;
    return await db.query('categories', orderBy: 'id ASC');
  }

  Future<int> insertCategory(String name, String desc, String icon) async {
    final db = await instance.database;
    return await db.insert('categories', {'name': name, 'description': desc, 'icon': icon});
  }

  Future<int> updateCategory(int id, String name, String desc, String icon) async {
    final db = await instance.database;
    return await db.update('categories', {'name': name, 'description': desc, 'icon': icon}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCategory(int id) async {
    final db = await instance.database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // عمليات الأذكار
  Future<List<Map<String, dynamic>>> getAzkarByCategory(int categoryId) async {
    final db = await instance.database;
    return await db.query('azkar', where: 'categoryId = ?', whereArgs: [categoryId], orderBy: 'id ASC');
  }

  Future<int> insertZekr(int categoryId, String text, String benefit, int target) async {
    final db = await instance.database;
    return await db.insert('azkar', {'categoryId': categoryId, 'text': text, 'benefit': benefit, 'targetCount': target});
  }

  Future<int> updateZekr(int id, String text, String benefit, int target) async {
    final db = await instance.database;
    return await db.update('azkar', {'text': text, 'benefit': benefit, 'targetCount': target}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteZekr(int id) async {
    final db = await instance.database;
    return await db.delete('azkar', where: 'id = ?', whereArgs: [id]);
  }
}

// ------------------- واجهات التطبيق (UI) -------------------

// 1. الشاشة الرئيسية للأقسام
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<Map<String, dynamic>>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _refreshCategories();
  }

  void _refreshCategories() {
    setState(() {
      _categoriesFuture = DatabaseHelper.instance.getCategories();
    });
  }

  void _showCategoryDialog([Map<String, dynamic>? category]) {
    final nameController = TextEditingController(text: category?['name'] ?? '');
    final descController = TextEditingController(text: category?['description'] ?? '');
    final iconController = TextEditingController(text: category?['icon'] ?? '📖');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B4332),
        title: Text(
          category == null ? 'إضافة قسم جديد' : 'تعديل القسم',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'اسم القسم', labelStyle: TextStyle(color: Colors.white70)),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'الوصف المختصر', labelStyle: TextStyle(color: Colors.white70)),
            ),
            TextField(
              controller: iconController,
              decoration: const InputDecoration(labelText: 'رمز تعبيري (مثل 🤲)', labelStyle: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF52B788)),
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;

              if (category == null) {
                await DatabaseHelper.instance.insertCategory(
                  nameController.text.trim(),
                  descController.text.trim(),
                  iconController.text.trim().isEmpty ? '📖' : iconController.text.trim(),
                );
              } else {
                await DatabaseHelper.instance.updateCategory(
                  category['id'],
                  nameController.text.trim(),
                  descController.text.trim(),
                  iconController.text.trim().isEmpty ? '📖' : iconController.text.trim(),
                );
              }
              Navigator.pop(ctx);
              _refreshCategories();
            },
            child: const Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زاد الذاكرين', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF52B788),
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.create_new_folder, color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF52B788)));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('لا توجد أقسام حالياً'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final cat = items[index];
              return Card(
                color: const Color(0xFF1B4332),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: Text(cat['icon'], style: const TextStyle(fontSize: 26)),
                  title: Text(cat['name'], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  subtitle: Text(cat['description'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18, color: Colors.white54),
                        onPressed: () => _showCategoryDialog(cat),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                        onPressed: () async {
                          await DatabaseHelper.instance.deleteCategory(cat['id']);
                          _refreshCategories();
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemsListScreen(
                          categoryId: cat['id'],
                          categoryTitle: cat['name'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// 2. شاشة قائمة الأذكار لكل قسم
class ItemsListScreen extends StatefulWidget {
  final int categoryId;
  final String categoryTitle;

  const ItemsListScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  State<ItemsListScreen> createState() => _ItemsListScreenState();
}

class _ItemsListScreenState extends State<ItemsListScreen> {
  late Future<List<Map<String, dynamic>>> _azkarFuture;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    setState(() {
      _azkarFuture = DatabaseHelper.instance.getAzkarByCategory(widget.categoryId);
    });
  }

  void _openItemDialog([Map<String, dynamic>? item]) {
    final textController = TextEditingController(text: item?['text'] ?? '');
    final benefitController = TextEditingController(text: item?['benefit'] ?? '');
    final countController = TextEditingController(text: item?['targetCount']?.toString() ?? '33');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B4332),
        title: Text(
          item == null ? 'إضافة ذكر جديد' : 'تعديل الذكر',
          style: const TextStyle(color: Colors.white),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'نص الذكر',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: benefitController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'الفضل / الفائدة',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: countController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'العدد المستهدف',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF52B788)),
            onPressed: () async {
              if (textController.text.trim().isEmpty) return;
              final target = int.tryParse(countController.text) ?? 33;

              if (item == null) {
                await DatabaseHelper.instance.insertZekr(
                  widget.categoryId,
                  textController.text.trim(),
                  benefitController.text.trim(),
                  target,
                );
              } else {
                await DatabaseHelper.instance.updateZekr(
                  item['id'],
                  textController.text.trim(),
                  benefitController.text.trim(),
                  target,
                );
              }
              Navigator.pop(ctx);
              _refreshList();
            },
            child: const Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF52B788),
        onPressed: () => _openItemDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _azkarFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF52B788)));
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('لا توجد أذكار مضافة'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final zekr = items[index];
              return Card(
                color: const Color(0xFF2D6A4F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    zekr['text'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'الهدف: ${zekr['targetCount']} | ${zekr['benefit']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20, color: Colors.white70),
                        onPressed: () => _openItemDialog(zekr),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                        onPressed: () async {
                          await DatabaseHelper.instance.deleteZekr(zekr['id']);
                          _refreshList();
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CounterScreen(
                          text: zekr['text'],
                          benefit: zekr['benefit'],
                          targetCount: zekr['targetCount'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// 3. شاشة العداد التفاعلي الدائري
class CounterScreen extends StatefulWidget {
  final String text;
  final String benefit;
  final int targetCount;

  const CounterScreen({
    super.key,
    required this.text,
    required this.benefit,
    required this.targetCount,
  });

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  int currentCount = 0;

  void _increment() {
    HapticFeedback.lightImpact();
    setState(() {
      if (currentCount < widget.targetCount) {
        currentCount++;
      } else {
        HapticFeedback.vibrate();
      }
    });
  }

  void _reset() {
    setState(() {
      currentCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.targetCount == 0 ? 0.0 : currentCount / widget.targetCount;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reset),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _increment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: SingleChildScrollView(
                    child: Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.6),
                    ),
                  ),
                ),
              ),
              if (widget.benefit.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    widget.benefit,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF95D5B2), height: 1.4),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Expanded(
                flex: 3,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 230,
                        height: 230,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 14,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF52B788)),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$currentCount',
                            style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'من أصل ${widget.targetCount}',
                            style: const TextStyle(fontSize: 16, color: Colors.white54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Text('اضغط في أي مكان بالشاشة للتسبيح', style: TextStyle(color: Colors.white38)),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
