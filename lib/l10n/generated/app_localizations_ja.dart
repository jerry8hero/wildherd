// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'WildHerd';

  @override
  String get home => 'ホーム';

  @override
  String get pets => 'ペット';

  @override
  String get encyclopedia => '事典';

  @override
  String get market => '市場';

  @override
  String get habitat => '環境';

  @override
  String get information => '情報';

  @override
  String get companion => '混育';

  @override
  String get community => 'コミュニティ';

  @override
  String get settings => '設定';

  @override
  String get notifications => '通知';

  @override
  String get welcome => 'WildHerd愛好家へようこそ！';

  @override
  String petCount(int count) {
    return 'ペットは$count匹';
  }

  @override
  String get myPets => 'マイペット';

  @override
  String get noPets => 'ペットがまだいません';

  @override
  String get addFirstPet => '下の「+」をタップして最初のペットを追加';

  @override
  String get recommended => 'おすすめ';

  @override
  String difficulty(int difficulty) {
    return '難易度$difficulty';
  }

  @override
  String lifespan(int years) {
    return '$years年';
  }

  @override
  String recommendedFor(String level) {
    return '$levelおすすめ';
  }

  @override
  String get priceDynamic => '価格動向';

  @override
  String get priceTrend => '人気のペット価格走势を確認';

  @override
  String get exhibitionInfo => '展示会情報';

  @override
  String get exhibitionDesc => '展示会イベント＆飼育知識';

  @override
  String get quickFunctions => 'クイック機能';

  @override
  String get feedingRecord => '餌やり記録';

  @override
  String get healthRecord => '健康記録';

  @override
  String get growthAlbum => '成長アルバム';

  @override
  String get todayReminder => '今日のリマインダー';

  @override
  String get keepHumidity => 'ケージの湿度を保つ';

  @override
  String get observeStatus => 'ペットの状態を確認';

  @override
  String get checkHeater => 'ヒーター設備をチェック';

  @override
  String get ensureTemp => '適切な温度を確保';

  @override
  String get beginner => '初心者';

  @override
  String get intermediate => '中級者';

  @override
  String get expert => '上級者';

  @override
  String get selectLevel => 'ペット経験レベルを選択';

  @override
  String get beginnerDesc => '始めたばかりの初心者向け';

  @override
  String get intermediateDesc => '経験のあるオーナー向け';

  @override
  String get expertDesc => '経験豊富なオーナー向け';

  @override
  String get confirm => '確認';

  @override
  String get cancel => 'キャンセル';

  @override
  String get searchPet => 'ペット品種を検索...';

  @override
  String get priceRange => '価格帯';

  @override
  String get trend => 'トレンド';

  @override
  String get priceAlert => '値下げアラート';

  @override
  String get setPriceAlert => 'アラートを設定';

  @override
  String get targetPrice => '目標価格';

  @override
  String get currentPrice => '現在価格';

  @override
  String get lowestPrice => '最低価格';

  @override
  String get highestPrice => '最高価格';

  @override
  String get avgPrice => '平均価格';

  @override
  String get category => 'カテゴリー';

  @override
  String get snakes => 'ヘビ';

  @override
  String get lizards => 'トカゲ';

  @override
  String get turtles => '亀';

  @override
  String get geckos => 'ヤモリ';

  @override
  String get amphibians => '両生類';

  @override
  String get spiders => 'スパイダー';

  @override
  String get insects => '昆虫';

  @override
  String get mammals => '哺乳類';

  @override
  String get birds => '鳥類';

  @override
  String get fish => '魚類';

  @override
  String get introduction => '紹介';

  @override
  String get basicInfo => '基本情報';

  @override
  String get environmentReq => '環境要件';

  @override
  String get foodRecommendation => '餌の推奨';

  @override
  String get feedingFrequency => '餌やり頻度';

  @override
  String get selectionTips => '選び方のヒント';

  @override
  String get nameChinese => '中国語名';

  @override
  String get nameEnglish => '英語名';

  @override
  String get scientificName => '学名';

  @override
  String get difficultyLevel => '難易度';

  @override
  String get lifespanYear => '寿命';

  @override
  String get categoryType => 'カテゴリー';

  @override
  String get temperature => '温度';

  @override
  String get humidity => '湿度';

  @override
  String get lighting => '照明';

  @override
  String get temperatureRange => '温度範囲';

  @override
  String get humidityRange => '湿度範囲';

  @override
  String get daytimeTemp => '日中温度';

  @override
  String get nightTemp => '夜間温度';

  @override
  String get baskingTemp => 'バスキング温度';

  @override
  String get habitatMonitor => '環境モニター';

  @override
  String get currentTemp => '現在の温度';

  @override
  String get currentHumidity => '現在の湿度';

  @override
  String get environmentScore => '環境スコア';

  @override
  String get improvement => '改善案';

  @override
  String get temperatureStatus => '温度状態';

  @override
  String get humidityStatus => '湿度状態';

  @override
  String get normal => '正常';

  @override
  String get tooHigh => '高め';

  @override
  String get tooLow => '低め';

  @override
  String get editHabitat => '環境を編集';

  @override
  String get compareHabitats => '環境を比較';

  @override
  String get addHabitat => 'いを追加';

  @override
  String get exhibitionActivity => '展示会';

  @override
  String get careKnowledge => '飼育知識';

  @override
  String get upcomingEvents => '開催予定';

  @override
  String get ongoingEvents => '開催中';

  @override
  String get pastEvents => '終了';

  @override
  String get readMore => '続きを読む';

  @override
  String get publishDate => '公開日';

  @override
  String get compatibility => '相性';

  @override
  String get compatible => '混育可能';

  @override
  String get incompatible => '混育不可';

  @override
  String get caution => '注意';

  @override
  String get notes => 'メモ';

  @override
  String get recommendedScheme => '推奨プラン';

  @override
  String get checkCompatibility => '相性をチェック';

  @override
  String get feedRecord => '餌やり記録';

  @override
  String get weightRecord => '体重記録';

  @override
  String get moltRecord => '脱皮記録';

  @override
  String get healthCheck => '健康チェック';

  @override
  String get addRecord => '記録を追加';

  @override
  String get noRecords => '記録なし';

  @override
  String get addFirstRecord => '+ をタップして最初の記録を追加';

  @override
  String get recordDate => '記録日';

  @override
  String get notesField => 'メモ';

  @override
  String get posts => '投稿';

  @override
  String get newPost => '新規投稿';

  @override
  String get like => 'いいね';

  @override
  String get comment => 'コメント';

  @override
  String get share => 'シェア';

  @override
  String get writeComment => 'コメントを書く...';

  @override
  String get noPosts => '投稿なし';

  @override
  String get publish => '投稿する';

  @override
  String get language => '言語';

  @override
  String get selectLanguage => '言語を選択';

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
  String get loading => '読み込み中...';

  @override
  String get loadFailed => '読み込み失敗';

  @override
  String get retry => '再試行';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get edit => '編集';

  @override
  String get add => '追加';

  @override
  String get addPet => 'ペットを追加';

  @override
  String get close => '閉じる';

  @override
  String get confirmDelete => '削除を確認';

  @override
  String get success => '成功';

  @override
  String get error => 'エラー';

  @override
  String get warning => '警告';

  @override
  String get male => '雄';

  @override
  String get female => '雌';

  @override
  String get unknown => '不明';

  @override
  String get age => '年齢';

  @override
  String get weight => '体重';

  @override
  String get birthDate => '生年月日';

  @override
  String get acquisitionDate => '入手日';

  @override
  String get temperatureUnit => '°C';

  @override
  String get weightUnit => 'g';

  @override
  String get lengthUnit => 'cm';

  @override
  String get editPet => 'ペットを編集';

  @override
  String get petDetails => 'ペット詳細';

  @override
  String get deletePet => 'ペットを削除';

  @override
  String get petName => 'ペット名';

  @override
  String get speciesSelect => '種類を選択';

  @override
  String get morph => 'モルフ';

  @override
  String get birthday => '誕生日';

  @override
  String get gender => '性別';

  @override
  String get noData => 'データなし';

  @override
  String get noRelatedData => '関連データなし';

  @override
  String get pullToRefresh => '引っ張って更新';

  @override
  String get releaseToRefresh => '離して更新';

  @override
  String get recentNews => '最新ニュース';

  @override
  String get hotSpecies => '人気種';

  @override
  String get priceUp => '上昇';

  @override
  String get priceDown => '下落';

  @override
  String get priceStable => '安定';

  @override
  String get viewAll => 'すべて見る';

  @override
  String get more => 'もっと';

  @override
  String get less => '閉じる';
}
