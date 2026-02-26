import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// 应用名称
  ///
  /// In zh, this message translates to:
  /// **'WildHerd'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get home;

  /// No description provided for @pets.
  ///
  /// In zh, this message translates to:
  /// **'宠物'**
  String get pets;

  /// No description provided for @encyclopedia.
  ///
  /// In zh, this message translates to:
  /// **'百科'**
  String get encyclopedia;

  /// No description provided for @market.
  ///
  /// In zh, this message translates to:
  /// **'行情'**
  String get market;

  /// No description provided for @habitat.
  ///
  /// In zh, this message translates to:
  /// **'环境'**
  String get habitat;

  /// No description provided for @information.
  ///
  /// In zh, this message translates to:
  /// **'资讯'**
  String get information;

  /// No description provided for @companion.
  ///
  /// In zh, this message translates to:
  /// **'混养'**
  String get companion;

  /// No description provided for @community.
  ///
  /// In zh, this message translates to:
  /// **'社区'**
  String get community;

  /// No description provided for @settings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get notifications;

  /// No description provided for @welcome.
  ///
  /// In zh, this message translates to:
  /// **'你好，WildHerd 爱好者！'**
  String get welcome;

  /// No description provided for @petCount.
  ///
  /// In zh, this message translates to:
  /// **'共有 {count} 只宠物'**
  String petCount(int count);

  /// No description provided for @myPets.
  ///
  /// In zh, this message translates to:
  /// **'我的宠物'**
  String get myPets;

  /// No description provided for @noPets.
  ///
  /// In zh, this message translates to:
  /// **'还没有添加宠物'**
  String get noPets;

  /// No description provided for @addFirstPet.
  ///
  /// In zh, this message translates to:
  /// **'点击下方\"+\"添加你的第一只宠物'**
  String get addFirstPet;

  /// No description provided for @recommended.
  ///
  /// In zh, this message translates to:
  /// **'推荐'**
  String get recommended;

  /// No description provided for @difficulty.
  ///
  /// In zh, this message translates to:
  /// **'难度{difficulty}'**
  String difficulty(int difficulty);

  /// No description provided for @lifespan.
  ///
  /// In zh, this message translates to:
  /// **'{years}年'**
  String lifespan(int years);

  /// No description provided for @recommendedFor.
  ///
  /// In zh, this message translates to:
  /// **'{level}推荐'**
  String recommendedFor(String level);

  /// No description provided for @priceDynamic.
  ///
  /// In zh, this message translates to:
  /// **'价格动态'**
  String get priceDynamic;

  /// No description provided for @priceTrend.
  ///
  /// In zh, this message translates to:
  /// **'查看热门宠物价格走势'**
  String get priceTrend;

  /// No description provided for @exhibitionInfo.
  ///
  /// In zh, this message translates to:
  /// **'展览资讯'**
  String get exhibitionInfo;

  /// No description provided for @exhibitionDesc.
  ///
  /// In zh, this message translates to:
  /// **'展览活动预告 & 饲养知识'**
  String get exhibitionDesc;

  /// No description provided for @quickFunctions.
  ///
  /// In zh, this message translates to:
  /// **'快捷功能'**
  String get quickFunctions;

  /// No description provided for @feedingRecord.
  ///
  /// In zh, this message translates to:
  /// **'喂食记录'**
  String get feedingRecord;

  /// No description provided for @healthRecord.
  ///
  /// In zh, this message translates to:
  /// **'健康记录'**
  String get healthRecord;

  /// No description provided for @growthAlbum.
  ///
  /// In zh, this message translates to:
  /// **'成长相册'**
  String get growthAlbum;

  /// No description provided for @todayReminder.
  ///
  /// In zh, this message translates to:
  /// **'今日提醒'**
  String get todayReminder;

  /// No description provided for @keepHumidity.
  ///
  /// In zh, this message translates to:
  /// **'保持饲养箱湿度'**
  String get keepHumidity;

  /// No description provided for @observeStatus.
  ///
  /// In zh, this message translates to:
  /// **'注意观察宠物状态'**
  String get observeStatus;

  /// No description provided for @checkHeater.
  ///
  /// In zh, this message translates to:
  /// **'检查加热设备'**
  String get checkHeater;

  /// No description provided for @ensureTemp.
  ///
  /// In zh, this message translates to:
  /// **'确保温度适宜'**
  String get ensureTemp;

  /// No description provided for @beginner.
  ///
  /// In zh, this message translates to:
  /// **'新手'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In zh, this message translates to:
  /// **'进阶'**
  String get intermediate;

  /// No description provided for @expert.
  ///
  /// In zh, this message translates to:
  /// **'资深'**
  String get expert;

  /// No description provided for @selectLevel.
  ///
  /// In zh, this message translates to:
  /// **'选择你的养宠经验等级'**
  String get selectLevel;

  /// No description provided for @beginnerDesc.
  ///
  /// In zh, this message translates to:
  /// **'适合刚入门的新手玩家'**
  String get beginnerDesc;

  /// No description provided for @intermediateDesc.
  ///
  /// In zh, this message translates to:
  /// **'有一定饲养经验的玩家'**
  String get intermediateDesc;

  /// No description provided for @expertDesc.
  ///
  /// In zh, this message translates to:
  /// **'经验丰富的老手玩家'**
  String get expertDesc;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @searchPet.
  ///
  /// In zh, this message translates to:
  /// **'搜索宠物品种...'**
  String get searchPet;

  /// No description provided for @priceRange.
  ///
  /// In zh, this message translates to:
  /// **'价格区间'**
  String get priceRange;

  /// No description provided for @trend.
  ///
  /// In zh, this message translates to:
  /// **'趋势'**
  String get trend;

  /// No description provided for @priceAlert.
  ///
  /// In zh, this message translates to:
  /// **'降价提醒'**
  String get priceAlert;

  /// No description provided for @setPriceAlert.
  ///
  /// In zh, this message translates to:
  /// **'设置价格提醒'**
  String get setPriceAlert;

  /// No description provided for @targetPrice.
  ///
  /// In zh, this message translates to:
  /// **'目标价格'**
  String get targetPrice;

  /// No description provided for @currentPrice.
  ///
  /// In zh, this message translates to:
  /// **'当前价格'**
  String get currentPrice;

  /// No description provided for @lowestPrice.
  ///
  /// In zh, this message translates to:
  /// **'最低价'**
  String get lowestPrice;

  /// No description provided for @highestPrice.
  ///
  /// In zh, this message translates to:
  /// **'最高价'**
  String get highestPrice;

  /// No description provided for @avgPrice.
  ///
  /// In zh, this message translates to:
  /// **'平均价'**
  String get avgPrice;

  /// No description provided for @category.
  ///
  /// In zh, this message translates to:
  /// **'分类'**
  String get category;

  /// No description provided for @snakes.
  ///
  /// In zh, this message translates to:
  /// **'蛇类'**
  String get snakes;

  /// No description provided for @lizards.
  ///
  /// In zh, this message translates to:
  /// **'蜥蜴'**
  String get lizards;

  /// No description provided for @turtles.
  ///
  /// In zh, this message translates to:
  /// **'龟类'**
  String get turtles;

  /// No description provided for @geckos.
  ///
  /// In zh, this message translates to:
  /// **'守宫'**
  String get geckos;

  /// No description provided for @amphibians.
  ///
  /// In zh, this message translates to:
  /// **'两栖'**
  String get amphibians;

  /// No description provided for @spiders.
  ///
  /// In zh, this message translates to:
  /// **'蜘蛛'**
  String get spiders;

  /// No description provided for @insects.
  ///
  /// In zh, this message translates to:
  /// **'昆虫'**
  String get insects;

  /// No description provided for @mammals.
  ///
  /// In zh, this message translates to:
  /// **'哺乳'**
  String get mammals;

  /// No description provided for @birds.
  ///
  /// In zh, this message translates to:
  /// **'鸟类'**
  String get birds;

  /// No description provided for @fish.
  ///
  /// In zh, this message translates to:
  /// **'鱼类'**
  String get fish;

  /// No description provided for @introduction.
  ///
  /// In zh, this message translates to:
  /// **'简介'**
  String get introduction;

  /// No description provided for @basicInfo.
  ///
  /// In zh, this message translates to:
  /// **'基本信息'**
  String get basicInfo;

  /// No description provided for @environmentReq.
  ///
  /// In zh, this message translates to:
  /// **'环境要求'**
  String get environmentReq;

  /// No description provided for @foodRecommendation.
  ///
  /// In zh, this message translates to:
  /// **'食物推荐'**
  String get foodRecommendation;

  /// No description provided for @feedingFrequency.
  ///
  /// In zh, this message translates to:
  /// **'喂食频率'**
  String get feedingFrequency;

  /// No description provided for @selectionTips.
  ///
  /// In zh, this message translates to:
  /// **'挑选技巧'**
  String get selectionTips;

  /// No description provided for @nameChinese.
  ///
  /// In zh, this message translates to:
  /// **'中文名'**
  String get nameChinese;

  /// No description provided for @nameEnglish.
  ///
  /// In zh, this message translates to:
  /// **'英文名'**
  String get nameEnglish;

  /// No description provided for @scientificName.
  ///
  /// In zh, this message translates to:
  /// **'学名'**
  String get scientificName;

  /// No description provided for @difficultyLevel.
  ///
  /// In zh, this message translates to:
  /// **'难度'**
  String get difficultyLevel;

  /// No description provided for @lifespanYear.
  ///
  /// In zh, this message translates to:
  /// **'寿命'**
  String get lifespanYear;

  /// No description provided for @categoryType.
  ///
  /// In zh, this message translates to:
  /// **'分类'**
  String get categoryType;

  /// No description provided for @temperature.
  ///
  /// In zh, this message translates to:
  /// **'温度'**
  String get temperature;

  /// No description provided for @humidity.
  ///
  /// In zh, this message translates to:
  /// **'湿度'**
  String get humidity;

  /// No description provided for @lighting.
  ///
  /// In zh, this message translates to:
  /// **'照明'**
  String get lighting;

  /// No description provided for @temperatureRange.
  ///
  /// In zh, this message translates to:
  /// **'温度范围'**
  String get temperatureRange;

  /// No description provided for @humidityRange.
  ///
  /// In zh, this message translates to:
  /// **'湿度范围'**
  String get humidityRange;

  /// No description provided for @daytimeTemp.
  ///
  /// In zh, this message translates to:
  /// **'白天温度'**
  String get daytimeTemp;

  /// No description provided for @nightTemp.
  ///
  /// In zh, this message translates to:
  /// **'夜间温度'**
  String get nightTemp;

  /// No description provided for @baskingTemp.
  ///
  /// In zh, this message translates to:
  /// **'晒台温度'**
  String get baskingTemp;

  /// No description provided for @habitatMonitor.
  ///
  /// In zh, this message translates to:
  /// **'环境监控'**
  String get habitatMonitor;

  /// No description provided for @currentTemp.
  ///
  /// In zh, this message translates to:
  /// **'当前温度'**
  String get currentTemp;

  /// No description provided for @currentHumidity.
  ///
  /// In zh, this message translates to:
  /// **'当前湿度'**
  String get currentHumidity;

  /// No description provided for @environmentScore.
  ///
  /// In zh, this message translates to:
  /// **'环境评分'**
  String get environmentScore;

  /// No description provided for @improvement.
  ///
  /// In zh, this message translates to:
  /// **'改进建议'**
  String get improvement;

  /// No description provided for @temperatureStatus.
  ///
  /// In zh, this message translates to:
  /// **'温度状态'**
  String get temperatureStatus;

  /// No description provided for @humidityStatus.
  ///
  /// In zh, this message translates to:
  /// **'湿度状态'**
  String get humidityStatus;

  /// No description provided for @normal.
  ///
  /// In zh, this message translates to:
  /// **'正常'**
  String get normal;

  /// No description provided for @tooHigh.
  ///
  /// In zh, this message translates to:
  /// **'偏高'**
  String get tooHigh;

  /// No description provided for @tooLow.
  ///
  /// In zh, this message translates to:
  /// **'偏低'**
  String get tooLow;

  /// No description provided for @editHabitat.
  ///
  /// In zh, this message translates to:
  /// **'编辑环境'**
  String get editHabitat;

  /// No description provided for @compareHabitats.
  ///
  /// In zh, this message translates to:
  /// **'对比环境'**
  String get compareHabitats;

  /// No description provided for @addHabitat.
  ///
  /// In zh, this message translates to:
  /// **'添加环境'**
  String get addHabitat;

  /// No description provided for @exhibitionActivity.
  ///
  /// In zh, this message translates to:
  /// **'展览活动'**
  String get exhibitionActivity;

  /// No description provided for @careKnowledge.
  ///
  /// In zh, this message translates to:
  /// **'饲养知识'**
  String get careKnowledge;

  /// No description provided for @upcomingEvents.
  ///
  /// In zh, this message translates to:
  /// **'即将开始'**
  String get upcomingEvents;

  /// No description provided for @ongoingEvents.
  ///
  /// In zh, this message translates to:
  /// **'正在进行'**
  String get ongoingEvents;

  /// No description provided for @pastEvents.
  ///
  /// In zh, this message translates to:
  /// **'已结束'**
  String get pastEvents;

  /// No description provided for @readMore.
  ///
  /// In zh, this message translates to:
  /// **'阅读更多'**
  String get readMore;

  /// No description provided for @publishDate.
  ///
  /// In zh, this message translates to:
  /// **'发布日期'**
  String get publishDate;

  /// No description provided for @compatibility.
  ///
  /// In zh, this message translates to:
  /// **'兼容性'**
  String get compatibility;

  /// No description provided for @compatible.
  ///
  /// In zh, this message translates to:
  /// **'可混养'**
  String get compatible;

  /// No description provided for @incompatible.
  ///
  /// In zh, this message translates to:
  /// **'不可混养'**
  String get incompatible;

  /// No description provided for @caution.
  ///
  /// In zh, this message translates to:
  /// **'需注意'**
  String get caution;

  /// No description provided for @notes.
  ///
  /// In zh, this message translates to:
  /// **'注意事项'**
  String get notes;

  /// No description provided for @recommendedScheme.
  ///
  /// In zh, this message translates to:
  /// **'推荐方案'**
  String get recommendedScheme;

  /// No description provided for @checkCompatibility.
  ///
  /// In zh, this message translates to:
  /// **'检查兼容性'**
  String get checkCompatibility;

  /// No description provided for @feedRecord.
  ///
  /// In zh, this message translates to:
  /// **'喂食记录'**
  String get feedRecord;

  /// No description provided for @weightRecord.
  ///
  /// In zh, this message translates to:
  /// **'体重记录'**
  String get weightRecord;

  /// No description provided for @moltRecord.
  ///
  /// In zh, this message translates to:
  /// **'蜕皮记录'**
  String get moltRecord;

  /// No description provided for @healthCheck.
  ///
  /// In zh, this message translates to:
  /// **'健康检查'**
  String get healthCheck;

  /// No description provided for @addRecord.
  ///
  /// In zh, this message translates to:
  /// **'添加记录'**
  String get addRecord;

  /// No description provided for @noRecords.
  ///
  /// In zh, this message translates to:
  /// **'暂无记录'**
  String get noRecords;

  /// No description provided for @addFirstRecord.
  ///
  /// In zh, this message translates to:
  /// **'点击\"+\"添加第一条记录'**
  String get addFirstRecord;

  /// No description provided for @recordDate.
  ///
  /// In zh, this message translates to:
  /// **'记录日期'**
  String get recordDate;

  /// No description provided for @notesField.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get notesField;

  /// No description provided for @posts.
  ///
  /// In zh, this message translates to:
  /// **'动态'**
  String get posts;

  /// No description provided for @newPost.
  ///
  /// In zh, this message translates to:
  /// **'发布动态'**
  String get newPost;

  /// No description provided for @like.
  ///
  /// In zh, this message translates to:
  /// **'点赞'**
  String get like;

  /// No description provided for @comment.
  ///
  /// In zh, this message translates to:
  /// **'评论'**
  String get comment;

  /// No description provided for @share.
  ///
  /// In zh, this message translates to:
  /// **'分享'**
  String get share;

  /// No description provided for @writeComment.
  ///
  /// In zh, this message translates to:
  /// **'写评论...'**
  String get writeComment;

  /// No description provided for @noPosts.
  ///
  /// In zh, this message translates to:
  /// **'暂无动态'**
  String get noPosts;

  /// No description provided for @publish.
  ///
  /// In zh, this message translates to:
  /// **'发布'**
  String get publish;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In zh, this message translates to:
  /// **'选择语言'**
  String get selectLanguage;

  /// No description provided for @chinese.
  ///
  /// In zh, this message translates to:
  /// **'简体中文'**
  String get chinese;

  /// No description provided for @english.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @japanese.
  ///
  /// In zh, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// No description provided for @korean.
  ///
  /// In zh, this message translates to:
  /// **'한국어'**
  String get korean;

  /// No description provided for @spanish.
  ///
  /// In zh, this message translates to:
  /// **'Español'**
  String get spanish;

  /// No description provided for @loading.
  ///
  /// In zh, this message translates to:
  /// **'加载中...'**
  String get loading;

  /// No description provided for @loadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get loadFailed;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get add;

  /// No description provided for @close.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get close;

  /// No description provided for @confirmDelete.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get confirmDelete;

  /// No description provided for @success.
  ///
  /// In zh, this message translates to:
  /// **'成功'**
  String get success;

  /// No description provided for @error.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get error;

  /// No description provided for @warning.
  ///
  /// In zh, this message translates to:
  /// **'警告'**
  String get warning;

  /// No description provided for @male.
  ///
  /// In zh, this message translates to:
  /// **'公'**
  String get male;

  /// No description provided for @female.
  ///
  /// In zh, this message translates to:
  /// **'母'**
  String get female;

  /// No description provided for @unknown.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get unknown;

  /// No description provided for @age.
  ///
  /// In zh, this message translates to:
  /// **'年龄'**
  String get age;

  /// No description provided for @weight.
  ///
  /// In zh, this message translates to:
  /// **'体重'**
  String get weight;

  /// No description provided for @birthDate.
  ///
  /// In zh, this message translates to:
  /// **'出生日期'**
  String get birthDate;

  /// No description provided for @acquisitionDate.
  ///
  /// In zh, this message translates to:
  /// **'入手日期'**
  String get acquisitionDate;

  /// No description provided for @temperatureUnit.
  ///
  /// In zh, this message translates to:
  /// **'°C'**
  String get temperatureUnit;

  /// No description provided for @weightUnit.
  ///
  /// In zh, this message translates to:
  /// **'g'**
  String get weightUnit;

  /// No description provided for @lengthUnit.
  ///
  /// In zh, this message translates to:
  /// **'cm'**
  String get lengthUnit;

  /// No description provided for @editPet.
  ///
  /// In zh, this message translates to:
  /// **'编辑宠物'**
  String get editPet;

  /// No description provided for @petDetails.
  ///
  /// In zh, this message translates to:
  /// **'宠物详情'**
  String get petDetails;

  /// No description provided for @deletePet.
  ///
  /// In zh, this message translates to:
  /// **'删除宠物'**
  String get deletePet;

  /// No description provided for @petName.
  ///
  /// In zh, this message translates to:
  /// **'宠物名称'**
  String get petName;

  /// No description provided for @speciesSelect.
  ///
  /// In zh, this message translates to:
  /// **'选择物种'**
  String get speciesSelect;

  /// No description provided for @morph.
  ///
  /// In zh, this message translates to:
  /// **'变异'**
  String get morph;

  /// No description provided for @birthday.
  ///
  /// In zh, this message translates to:
  /// **'生日'**
  String get birthday;

  /// No description provided for @gender.
  ///
  /// In zh, this message translates to:
  /// **'性别'**
  String get gender;

  /// No description provided for @noData.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get noData;

  /// No description provided for @noRelatedData.
  ///
  /// In zh, this message translates to:
  /// **'暂无相关数据'**
  String get noRelatedData;

  /// No description provided for @pullToRefresh.
  ///
  /// In zh, this message translates to:
  /// **'下拉刷新'**
  String get pullToRefresh;

  /// No description provided for @releaseToRefresh.
  ///
  /// In zh, this message translates to:
  /// **'释放刷新'**
  String get releaseToRefresh;

  /// No description provided for @recentNews.
  ///
  /// In zh, this message translates to:
  /// **'最新资讯'**
  String get recentNews;

  /// No description provided for @hotSpecies.
  ///
  /// In zh, this message translates to:
  /// **'热门物种'**
  String get hotSpecies;

  /// No description provided for @priceUp.
  ///
  /// In zh, this message translates to:
  /// **'上涨'**
  String get priceUp;

  /// No description provided for @priceDown.
  ///
  /// In zh, this message translates to:
  /// **'下跌'**
  String get priceDown;

  /// No description provided for @priceStable.
  ///
  /// In zh, this message translates to:
  /// **'平稳'**
  String get priceStable;

  /// No description provided for @viewAll.
  ///
  /// In zh, this message translates to:
  /// **'查看全部'**
  String get viewAll;

  /// No description provided for @more.
  ///
  /// In zh, this message translates to:
  /// **'更多'**
  String get more;

  /// No description provided for @less.
  ///
  /// In zh, this message translates to:
  /// **'收起'**
  String get less;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
