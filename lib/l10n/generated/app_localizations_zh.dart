// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'WildHerd';

  @override
  String get home => '首页';

  @override
  String get pets => '宠物';

  @override
  String get encyclopedia => '百科';

  @override
  String get market => '行情';

  @override
  String get habitat => '环境';

  @override
  String get information => '资讯';

  @override
  String get companion => '混养';

  @override
  String get community => '社区';

  @override
  String get settings => '设置';

  @override
  String get notifications => '通知';

  @override
  String get welcome => '你好，WildHerd 爱好者！';

  @override
  String petCount(int count) {
    return '共有 $count 只宠物';
  }

  @override
  String get myPets => '我的宠物';

  @override
  String get noPets => '还没有添加宠物';

  @override
  String get addFirstPet => '点击下方\"+\"添加你的第一只宠物';

  @override
  String get recommended => '推荐';

  @override
  String difficulty(int difficulty) {
    return '难度$difficulty';
  }

  @override
  String lifespan(int years) {
    return '$years年';
  }

  @override
  String recommendedFor(String level) {
    return '$level推荐';
  }

  @override
  String get priceDynamic => '价格动态';

  @override
  String get priceTrend => '查看热门宠物价格走势';

  @override
  String get exhibitionInfo => '展览资讯';

  @override
  String get exhibitionDesc => '展览活动预告 & 饲养知识';

  @override
  String get quickFunctions => '快捷功能';

  @override
  String get feedingRecord => '喂食记录';

  @override
  String get healthRecord => '健康记录';

  @override
  String get growthAlbum => '成长相册';

  @override
  String get todayReminder => '今日提醒';

  @override
  String get keepHumidity => '保持饲养箱湿度';

  @override
  String get observeStatus => '注意观察宠物状态';

  @override
  String get checkHeater => '检查加热设备';

  @override
  String get ensureTemp => '确保温度适宜';

  @override
  String get beginner => '新手';

  @override
  String get intermediate => '进阶';

  @override
  String get expert => '资深';

  @override
  String get selectLevel => '选择你的养宠经验等级';

  @override
  String get beginnerDesc => '适合刚入门的新手玩家';

  @override
  String get intermediateDesc => '有一定饲养经验的玩家';

  @override
  String get expertDesc => '经验丰富的老手玩家';

  @override
  String get confirm => '确认';

  @override
  String get cancel => '取消';

  @override
  String get searchPet => '搜索宠物品种...';

  @override
  String get priceRange => '价格区间';

  @override
  String get trend => '趋势';

  @override
  String get priceAlert => '降价提醒';

  @override
  String get setPriceAlert => '设置价格提醒';

  @override
  String get targetPrice => '目标价格';

  @override
  String get currentPrice => '当前价格';

  @override
  String get lowestPrice => '最低价';

  @override
  String get highestPrice => '最高价';

  @override
  String get avgPrice => '平均价';

  @override
  String get category => '分类';

  @override
  String get snakes => '蛇类';

  @override
  String get lizards => '蜥蜴';

  @override
  String get turtles => '龟类';

  @override
  String get geckos => '守宫';

  @override
  String get amphibians => '两栖';

  @override
  String get spiders => '蜘蛛';

  @override
  String get insects => '昆虫';

  @override
  String get mammals => '哺乳';

  @override
  String get birds => '鸟类';

  @override
  String get fish => '鱼类';

  @override
  String get introduction => '简介';

  @override
  String get basicInfo => '基本信息';

  @override
  String get environmentReq => '环境要求';

  @override
  String get foodRecommendation => '食物推荐';

  @override
  String get feedingFrequency => '喂食频率';

  @override
  String get selectionTips => '挑选技巧';

  @override
  String get nameChinese => '中文名';

  @override
  String get nameEnglish => '英文名';

  @override
  String get scientificName => '学名';

  @override
  String get difficultyLevel => '难度';

  @override
  String get lifespanYear => '寿命';

  @override
  String get categoryType => '分类';

  @override
  String get temperature => '温度';

  @override
  String get humidity => '湿度';

  @override
  String get lighting => '照明';

  @override
  String get temperatureRange => '温度范围';

  @override
  String get humidityRange => '湿度范围';

  @override
  String get daytimeTemp => '白天温度';

  @override
  String get nightTemp => '夜间温度';

  @override
  String get baskingTemp => '晒台温度';

  @override
  String get habitatMonitor => '环境监控';

  @override
  String get currentTemp => '当前温度';

  @override
  String get currentHumidity => '当前湿度';

  @override
  String get environmentScore => '环境评分';

  @override
  String get improvement => '改进建议';

  @override
  String get temperatureStatus => '温度状态';

  @override
  String get humidityStatus => '湿度状态';

  @override
  String get normal => '正常';

  @override
  String get tooHigh => '偏高';

  @override
  String get tooLow => '偏低';

  @override
  String get editHabitat => '编辑环境';

  @override
  String get compareHabitats => '对比环境';

  @override
  String get addHabitat => '添加环境';

  @override
  String get exhibitionActivity => '展览活动';

  @override
  String get careKnowledge => '饲养知识';

  @override
  String get upcomingEvents => '即将开始';

  @override
  String get ongoingEvents => '正在进行';

  @override
  String get pastEvents => '已结束';

  @override
  String get readMore => '阅读更多';

  @override
  String get publishDate => '发布日期';

  @override
  String get compatibility => '兼容性';

  @override
  String get compatible => '可混养';

  @override
  String get incompatible => '不可混养';

  @override
  String get caution => '需注意';

  @override
  String get notes => '注意事项';

  @override
  String get recommendedScheme => '推荐方案';

  @override
  String get checkCompatibility => '检查兼容性';

  @override
  String get feedRecord => '喂食记录';

  @override
  String get weightRecord => '体重记录';

  @override
  String get moltRecord => '蜕皮记录';

  @override
  String get healthCheck => '健康检查';

  @override
  String get addRecord => '添加记录';

  @override
  String get noRecords => '暂无记录';

  @override
  String get recordDate => '记录日期';

  @override
  String get notesField => '备注';

  @override
  String get posts => '动态';

  @override
  String get newPost => '发布动态';

  @override
  String get like => '点赞';

  @override
  String get comment => '评论';

  @override
  String get share => '分享';

  @override
  String get writeComment => '写评论...';

  @override
  String get noPosts => '暂无动态';

  @override
  String get publish => '发布';

  @override
  String get language => '语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get chinese => '简体中文';

  @override
  String get english => 'English';

  @override
  String get japanese => '日本語';

  @override
  String get korean => '한국어';

  @override
  String get spanish => 'Español';

  @override
  String get loading => '加载中...';

  @override
  String get loadFailed => '加载失败';

  @override
  String get retry => '重试';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get add => '添加';

  @override
  String get close => '关闭';

  @override
  String get confirmDelete => '确认删除';

  @override
  String get success => '成功';

  @override
  String get error => '错误';

  @override
  String get warning => '警告';

  @override
  String get male => '公';

  @override
  String get female => '母';

  @override
  String get unknown => '未知';

  @override
  String get age => '年龄';

  @override
  String get weight => '体重';

  @override
  String get birthDate => '出生日期';

  @override
  String get acquisitionDate => '入手日期';

  @override
  String get temperatureUnit => '°C';

  @override
  String get weightUnit => 'g';

  @override
  String get lengthUnit => 'cm';

  @override
  String get editPet => '编辑宠物';

  @override
  String get petDetails => '宠物详情';

  @override
  String get deletePet => '删除宠物';

  @override
  String get petName => '宠物名称';

  @override
  String get speciesSelect => '选择物种';

  @override
  String get morph => '变异';

  @override
  String get birthday => '生日';

  @override
  String get gender => '性别';

  @override
  String get noData => '暂无数据';

  @override
  String get noRelatedData => '暂无相关数据';

  @override
  String get pullToRefresh => '下拉刷新';

  @override
  String get releaseToRefresh => '释放刷新';

  @override
  String get recentNews => '最新资讯';

  @override
  String get hotSpecies => '热门物种';

  @override
  String get priceUp => '上涨';

  @override
  String get priceDown => '下跌';

  @override
  String get priceStable => '平稳';

  @override
  String get viewAll => '查看全部';

  @override
  String get more => '更多';

  @override
  String get less => '收起';
}
