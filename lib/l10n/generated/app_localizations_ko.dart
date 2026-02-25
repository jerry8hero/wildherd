// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'WildHerd';

  @override
  String get home => '홈';

  @override
  String get pets => '펫';

  @override
  String get encyclopedia => '백과';

  @override
  String get market => '시장';

  @override
  String get habitat => '환경';

  @override
  String get information => '정보';

  @override
  String get companion => '함께 키우기';

  @override
  String get community => '커뮤니티';

  @override
  String get settings => '설정';

  @override
  String get notifications => '알림';

  @override
  String get welcome => 'WildHerd 사랑好자님 안녕하세요!';

  @override
  String petCount(int count) {
    return '펫 $count마리';
  }

  @override
  String get myPets => '내 펫';

  @override
  String get noPets => '아직 펫이 없습니다';

  @override
  String get addFirstPet => '아래 \'+\'를 눌러 첫 번째 펫을 추가하세요';

  @override
  String get recommended => '추천';

  @override
  String difficulty(int difficulty) {
    return '난이도 $difficulty';
  }

  @override
  String lifespan(int years) {
    return '$years년';
  }

  @override
  String recommendedFor(String level) {
    return '$level 추천';
  }

  @override
  String get priceDynamic => '가격 동향';

  @override
  String get priceTrend => '인기 펫 가격 추이 보기';

  @override
  String get exhibitionInfo => '전시 정보';

  @override
  String get exhibitionDesc => '전시 행사 &饲养 지식';

  @override
  String get quickFunctions => '빠른 기능';

  @override
  String get feedingRecord => '급이 기록';

  @override
  String get healthRecord => '건강 기록';

  @override
  String get growthAlbum => '성장 앨범';

  @override
  String get todayReminder => '오늘의 알림';

  @override
  String get keepHumidity => '사육함 습도 유지';

  @override
  String get observeStatus => '펫 상태 관찰';

  @override
  String get checkHeater => '加热 장비 확인';

  @override
  String get ensureTemp => '적절한 온도 확보';

  @override
  String get beginner => '초급';

  @override
  String get intermediate => '중급';

  @override
  String get expert => '고급';

  @override
  String get selectLevel => '경험 수준 선택';

  @override
  String get beginnerDesc => '초보 사육자向け';

  @override
  String get intermediateDesc => '경험이 있는 사육자向け';

  @override
  String get expertDesc => '숙련된 사육자向け';

  @override
  String get confirm => '확인';

  @override
  String get cancel => '취소';

  @override
  String get searchPet => '펫品種 검색...';

  @override
  String get priceRange => '가격대';

  @override
  String get trend => '추세';

  @override
  String get priceAlert => '가격 알림';

  @override
  String get setPriceAlert => '가격 알림 설정';

  @override
  String get targetPrice => '목표 가격';

  @override
  String get currentPrice => '현재 가격';

  @override
  String get lowestPrice => '최저가';

  @override
  String get highestPrice => '최고가';

  @override
  String get avgPrice => '평균가';

  @override
  String get category => '카테고리';

  @override
  String get snakes => '뱀';

  @override
  String get lizards => '도마뱀';

  @override
  String get turtles => '거북';

  @override
  String get geckos => '도마뱀붙이';

  @override
  String get amphibians => '양서류';

  @override
  String get spiders => '거미';

  @override
  String get insects => '곤충';

  @override
  String get mammals => '포유류';

  @override
  String get birds => '조류';

  @override
  String get fish => '어류';

  @override
  String get introduction => '介绍';

  @override
  String get basicInfo => '기본 정보';

  @override
  String get environmentReq => '환경 요구사항';

  @override
  String get foodRecommendation => '먹이 추천';

  @override
  String get feedingFrequency => '급이 빈도';

  @override
  String get selectionTips => '선택 팁';

  @override
  String get nameChinese => '중국어 이름';

  @override
  String get nameEnglish => '영어 이름';

  @override
  String get scientificName => '학명';

  @override
  String get difficultyLevel => '난이도';

  @override
  String get lifespanYear => '수명';

  @override
  String get categoryType => '카테고리';

  @override
  String get temperature => '온도';

  @override
  String get humidity => '습도';

  @override
  String get lighting => '조명';

  @override
  String get temperatureRange => '온도 범위';

  @override
  String get humidityRange => '습도 범위';

  @override
  String get daytimeTemp => '주간 온도';

  @override
  String get nightTemp => '야간 온도';

  @override
  String get baskingTemp => '무리 온도';

  @override
  String get habitatMonitor => '환경 모니터';

  @override
  String get currentTemp => '현재 온도';

  @override
  String get currentHumidity => '현재 습도';

  @override
  String get environmentScore => '환경 점수';

  @override
  String get improvement => '개선 제안';

  @override
  String get temperatureStatus => '온도 상태';

  @override
  String get humidityStatus => '습도 상태';

  @override
  String get normal => '정상';

  @override
  String get tooHigh => '높음';

  @override
  String get tooLow => '낮음';

  @override
  String get editHabitat => '환경 편집';

  @override
  String get compareHabitats => '환경 비교';

  @override
  String get addHabitat => '환경 추가';

  @override
  String get exhibitionActivity => '전시회';

  @override
  String get careKnowledge => '饲养 지식';

  @override
  String get upcomingEvents => '예정';

  @override
  String get ongoingEvents => '진행 중';

  @override
  String get pastEvents => '종료';

  @override
  String get readMore => '더 보기';

  @override
  String get publishDate => '게시일';

  @override
  String get compatibility => '호환성';

  @override
  String get compatible => '함께 키우기 가능';

  @override
  String get incompatible => '함께 키우기 불가';

  @override
  String get caution => '주의';

  @override
  String get notes => '메모';

  @override
  String get recommendedScheme => '推荐方案';

  @override
  String get checkCompatibility => '호환성 검사';

  @override
  String get feedRecord => '급이 기록';

  @override
  String get weightRecord => '체중 기록';

  @override
  String get moltRecord => '탈피 기록';

  @override
  String get healthCheck => '건강 검사';

  @override
  String get addRecord => '기록 추가';

  @override
  String get noRecords => '기록 없음';

  @override
  String get addFirstRecord => '+ 를 눌러 첫 번째 기록을 추가하세요';

  @override
  String get recordDate => '기록 날짜';

  @override
  String get notesField => '메모';

  @override
  String get posts => '게시물';

  @override
  String get newPost => '새 게시물';

  @override
  String get like => '좋아요';

  @override
  String get comment => '댓글';

  @override
  String get share => '공유';

  @override
  String get writeComment => '댓글 작성...';

  @override
  String get noPosts => '게시물 없음';

  @override
  String get publish => '게시';

  @override
  String get language => '언어';

  @override
  String get selectLanguage => '언어 선택';

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
  String get loading => '로딩 중...';

  @override
  String get loadFailed => '로딩 실패';

  @override
  String get retry => '재시도';

  @override
  String get save => '저장';

  @override
  String get delete => '삭제';

  @override
  String get edit => '편집';

  @override
  String get add => '추가';

  @override
  String get close => '닫기';

  @override
  String get confirmDelete => '삭제 확인';

  @override
  String get success => '성공';

  @override
  String get error => '오류';

  @override
  String get warning => '경고';

  @override
  String get male => '수';

  @override
  String get female => '암';

  @override
  String get unknown => '불명';

  @override
  String get age => '나이';

  @override
  String get weight => '체중';

  @override
  String get birthDate => '생년월일';

  @override
  String get acquisitionDate => '入手일';

  @override
  String get temperatureUnit => '°C';

  @override
  String get weightUnit => 'g';

  @override
  String get lengthUnit => 'cm';

  @override
  String get editPet => '펫 편집';

  @override
  String get petDetails => '펫 상세';

  @override
  String get deletePet => '펫 삭제';

  @override
  String get petName => '펫 이름';

  @override
  String get speciesSelect => '종 선택';

  @override
  String get morph => '형태';

  @override
  String get birthday => '생일';

  @override
  String get gender => '성별';

  @override
  String get noData => '데이터 없음';

  @override
  String get noRelatedData => '관련 데이터 없음';

  @override
  String get pullToRefresh => '당겨서 새로고침';

  @override
  String get releaseToRefresh => '놓아서 새로고침';

  @override
  String get recentNews => '최신 뉴스';

  @override
  String get hotSpecies => '인기 종';

  @override
  String get priceUp => '상승';

  @override
  String get priceDown => '하락';

  @override
  String get priceStable => '안정';

  @override
  String get viewAll => '전체 보기';

  @override
  String get more => '더 보기';

  @override
  String get less => '접기';
}
