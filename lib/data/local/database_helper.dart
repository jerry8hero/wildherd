import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reptile_care.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 爬宠表
    await db.execute('''
      CREATE TABLE reptiles (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        species TEXT NOT NULL,
        species_chinese TEXT,
        gender TEXT,
        birth_date TEXT,
        weight REAL,
        length REAL,
        image_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 喂食记录表
    await db.execute('''
      CREATE TABLE feeding_records (
        id TEXT PRIMARY KEY,
        reptile_id TEXT NOT NULL,
        feeding_time TEXT NOT NULL,
        food_type TEXT NOT NULL,
        food_amount REAL,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (reptile_id) REFERENCES reptiles (id) ON DELETE CASCADE
      )
    ''');

    // 健康记录表
    await db.execute('''
      CREATE TABLE health_records (
        id TEXT PRIMARY KEY,
        reptile_id TEXT NOT NULL,
        record_date TEXT NOT NULL,
        weight REAL,
        length REAL,
        status TEXT,
        defecation TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (reptile_id) REFERENCES reptiles (id) ON DELETE CASCADE
      )
    ''');

    // 成长相册表
    await db.execute('''
      CREATE TABLE growth_photos (
        id TEXT PRIMARY KEY,
        reptile_id TEXT NOT NULL,
        image_path TEXT NOT NULL,
        description TEXT,
        photo_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (reptile_id) REFERENCES reptiles (id) ON DELETE CASCADE
      )
    ''');

    // 社区动态表
    await db.execute('''
      CREATE TABLE posts (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        user_name TEXT NOT NULL,
        user_avatar TEXT,
        content TEXT NOT NULL,
        images TEXT,
        reptile_species TEXT,
        likes INTEGER DEFAULT 0,
        comments INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 评论表
    await db.execute('''
      CREATE TABLE comments (
        id TEXT PRIMARY KEY,
        post_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        user_name TEXT NOT NULL,
        user_avatar TEXT,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (post_id) REFERENCES posts (id) ON DELETE CASCADE
      )
    ''');

    // 初始化一些示例百科数据
    await _initEncyclopediaData(db);
  }

  Future<void> _initEncyclopediaData(Database db) async {
    final speciesData = [
      {
        'id': '1',
        'name_chinese': '玉米蛇',
        'name_english': 'Corn Snake',
        'scientific_name': 'Pantherophis guttatus',
        'category': 'snake',
        'description': '玉米蛇是最受欢迎的宠物蛇之一，性格温顺，颜色多样。它们原产于北美，野生种群分布广泛。玉米蛇易于饲养，是新手入门的好选择。',
        'difficulty': 1,
        'lifespan': 15,
        'max_length': 180,
        'min_temp': 21,
        'max_temp': 32,
        'min_humidity': 40,
        'max_humidity': 60,
        'diet': 'carnivore',
      },
      {
        'id': '2',
        'name_chinese': '豹纹守宫',
        'name_english': 'Leopard Gecko',
        'scientific_name': 'Eublepharis macularius',
        'category': 'gecko',
        'description': '豹纹守宫是最受欢迎的宠物守宫之一，原产于巴基斯坦和印度。它们夜行性，性格温顺，容易饲养。各种基因变异使其拥有丰富的外表选择。',
        'difficulty': 1,
        'lifespan': 15,
        'max_length': 25,
        'min_temp': 24,
        'max_temp': 32,
        'min_humidity': 30,
        'max_humidity': 40,
        'diet': 'carnivore',
      },
      {
        'id': '3',
        'name_chinese': '绿鬣蜥',
        'name_english': 'Green Iguana',
        'scientific_name': 'Iguana iguana',
        'category': 'lizard',
        'description': '绿鬣蜥是大型蜥蜴，原产于中美洲和南美洲。它们需要较大的饲养空间和精心的照顾。成年后体型可达1.5米以上。',
        'difficulty': 3,
        'lifespan': 20,
        'max_length': 200,
        'min_temp': 24,
        'max_temp': 35,
        'min_humidity': 60,
        'max_humidity': 80,
        'diet': 'herbivore',
      },
      {
        'id': '4',
        'name_chinese': '红耳龟',
        'name_english': 'Red-eared Slider',
        'scientific_name': 'Trachemys scripta elegans',
        'category': 'turtle',
        'description': '红耳龟是最常见的宠物龟，原产于美国。它们水栖，需要水质管理和充足的晒背空间。杂食性，幼体偏肉食，成年后偏素食。',
        'difficulty': 2,
        'lifespan': 40,
        'max_length': 30,
        'min_temp': 20,
        'max_temp': 32,
        'min_humidity': 0,
        'max_humidity': 0,
        'diet': 'omnivore',
      },
      {
        'id': '5',
        'name_chinese': '鬃狮蜥',
        'name_english': 'Bearded Dragon',
        'scientific_name': 'Pogona vitticeps',
        'category': 'lizard',
        'description': '鬃狮蜥是澳洲特有的蜥蜴，性格温顺，是最受欢迎的宠物蜥蜴之一。它们日行性，需要充足的UVB光照。杂食性，适合新手饲养。',
        'difficulty': 1,
        'lifespan': 15,
        'max_length': 60,
        'min_temp': 24,
        'max_temp': 40,
        'min_humidity': 30,
        'max_humidity': 40,
        'diet': 'omnivore',
      },
      {
        'id': '6',
        'name_chinese': '球蟒',
        'name_english': 'Ball Python',
        'scientific_name': 'Python regius',
        'category': 'snake',
        'description': '球蟒是非洲最受欢迎的宠物蛇，因受到惊吓时会缩成球状而得名。它们性格温顺，体型适中，是很好的宠物蛇选择。',
        'difficulty': 2,
        'lifespan': 30,
        'max_length': 150,
        'min_temp': 24,
        'max_temp': 32,
        'min_humidity': 50,
        'max_humidity': 60,
        'diet': 'carnivore',
      },
    ];

    for (var species in speciesData) {
      await db.insert('species', species);
    }

    // 创建物种表（用于百科）
    await db.execute('''
      CREATE TABLE species (
        id TEXT PRIMARY KEY,
        name_chinese TEXT NOT NULL,
        name_english TEXT NOT NULL,
        scientific_name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        difficulty INTEGER NOT NULL,
        lifespan INTEGER NOT NULL,
        max_length REAL,
        min_temp REAL,
        max_temp REAL,
        min_humidity REAL,
        max_humidity REAL,
        diet TEXT NOT NULL,
        image_url TEXT
      )
    ''');

    // 重新插入物种数据
    for (var species in speciesData) {
      await db.insert('species', species);
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
