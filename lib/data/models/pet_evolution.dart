// 进化路线配置模型

import 'electronic_pet.dart';

/// 爬宠进化路线配置
class PetEvolutionData {
  /// 所有物种的进化路线配置
  static final List<EvolutionLine> evolutionLines = [
    // 玉米蛇进化线
    EvolutionLine(
      speciesId: 'corn_snake',
      speciesName: '玉米蛇',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'corn_snake_juvenile',
          nextName: '亚成体',
          requiredLevel: 5,
          requiredDays: 30,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'corn_snake_adult',
          nextName: '成体',
          requiredLevel: 15,
          requiredDays: 180,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'corn_snake_morph',
          nextName: '变异体',
          requiredLevel: 30,
          requiredDays: 365,
          requiredItemId: 'evolution_stone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '变异体',
        ),
      ],
    ),

    // 豹纹守宫进化线
    EvolutionLine(
      speciesId: 'leopard_gecko',
      speciesName: '豹纹守宫',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'leopard_gecko_juvenile',
          nextName: '亚成体',
          requiredLevel: 5,
          requiredDays: 30,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'leopard_gecko_adult',
          nextName: '成体',
          requiredLevel: 15,
          requiredDays: 180,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'giant_gecko',
          nextName: '巨人守宫',
          requiredLevel: 35,
          requiredDays: 500,
          requiredItemId: 'growth_hormone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '巨人守宫',
        ),
      ],
    ),

    // 鬃狮蜥进化线
    EvolutionLine(
      speciesId: 'bearded_dragon',
      speciesName: '鬃狮蜥',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'bearded_dragon_juvenile',
          nextName: '亚成体',
          requiredLevel: 8,
          requiredDays: 60,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'bearded_dragon_adult',
          nextName: '成体',
          requiredLevel: 20,
          requiredDays: 300,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'bearded_dragon_elite',
          nextName: '高冠变异',
          requiredLevel: 40,
          requiredDays: 600,
          requiredItemId: 'evolution_stone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '高冠变异',
        ),
      ],
    ),

    // 草龟进化线
    EvolutionLine(
      speciesId: 'chinese_turtle',
      speciesName: '草龟',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'chinese_turtle_juvenile',
          nextName: '亚成体',
          requiredLevel: 10,
          requiredDays: 90,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'chinese_turtle_adult',
          nextName: '成体',
          requiredLevel: 25,
          requiredDays: 730,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体(公)',
          nextSpeciesId: 'black_turtle',
          nextName: '墨化草龟',
          requiredLevel: 40,
          requiredDays: 1500,
          requiredItemId: 'ink_stone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '墨化草龟',
        ),
      ],
    ),

    // 绿鬣蜥进化线
    EvolutionLine(
      speciesId: 'green_iguana',
      speciesName: '绿鬣蜥',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'green_iguana_juvenile',
          nextName: '亚成体',
          requiredLevel: 10,
          requiredDays: 90,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'green_iguana_adult',
          nextName: '成体',
          requiredLevel: 25,
          requiredDays: 365,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'blue_iguana',
          nextName: '蓝鬣蜥',
          requiredLevel: 45,
          requiredDays: 730,
          requiredItemId: 'evolution_stone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '蓝鬣蜥',
        ),
      ],
    ),

    // 球蟒进化线
    EvolutionLine(
      speciesId: 'ball_python',
      speciesName: '球蟒',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'ball_python_juvenile',
          nextName: '亚成体',
          requiredLevel: 8,
          requiredDays: 60,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'ball_python_adult',
          nextName: '成体',
          requiredLevel: 20,
          requiredDays: 365,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'ball_python_morph',
          nextName: '变异球蟒',
          requiredLevel: 35,
          requiredDays: 730,
          requiredItemId: 'evolution_stone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '变异球蟒',
        ),
      ],
    ),

    // 睫角守宫进化线
    EvolutionLine(
      speciesId: 'crested_gecko',
      speciesName: '睫角守宫',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'crested_gecko_juvenile',
          nextName: '亚成体',
          requiredLevel: 5,
          requiredDays: 30,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'crested_gecko_adult',
          nextName: '成体',
          requiredLevel: 15,
          requiredDays: 180,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'harlequin_gecko',
          nextName: '小丑守宫',
          requiredLevel: 30,
          requiredDays: 400,
          requiredItemId: 'pattern_token',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '小丑守宫',
        ),
      ],
    ),

    // 红耳龟进化线
    EvolutionLine(
      speciesId: 'red_eared_slider',
      speciesName: '红耳龟',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'red_eared_slider_juvenile',
          nextName: '亚成体',
          requiredLevel: 8,
          requiredDays: 60,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'red_eared_slider_adult',
          nextName: '成体',
          requiredLevel: 20,
          requiredDays: 365,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'hypo_slider',
          nextName: '白化红耳龟',
          requiredLevel: 35,
          requiredDays: 730,
          requiredItemId: 'evolution_stone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '白化红耳龟',
        ),
      ],
    ),

    // 黑王蛇进化线
    EvolutionLine(
      speciesId: 'black_kingsnake',
      speciesName: '黑王蛇',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'black_kingsnake_juvenile',
          nextName: '亚成体',
          requiredLevel: 6,
          requiredDays: 45,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'black_kingsnake_adult',
          nextName: '成体',
          requiredLevel: 18,
          requiredDays: 200,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'mexican_black_kingsnake',
          nextName: '墨西哥黑王蛇',
          requiredLevel: 35,
          requiredDays: 400,
          requiredItemId: 'evolution_stone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '墨西哥黑王蛇',
        ),
      ],
    ),

    // 奶蛇进化线
    EvolutionLine(
      speciesId: 'milk_snake',
      speciesName: '奶蛇',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'milk_snake_juvenile',
          nextName: '亚成体',
          requiredLevel: 5,
          requiredDays: 30,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'milk_snake_adult',
          nextName: '成体',
          requiredLevel: 15,
          requiredDays: 180,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'honduran_milk_snake',
          nextName: '洪都拉斯奶蛇',
          requiredLevel: 30,
          requiredDays: 365,
          requiredItemId: 'pattern_token',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '洪都拉斯奶蛇',
        ),
      ],
    ),

    // 猪鼻蛇进化线
    EvolutionLine(
      speciesId: 'hognose_snake',
      speciesName: '猪鼻蛇',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'hognose_snake_juvenile',
          nextName: '亚成体',
          requiredLevel: 5,
          requiredDays: 30,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'hognose_snake_adult',
          nextName: '成体',
          requiredLevel: 15,
          requiredDays: 180,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'albino_hognose',
          nextName: '白化猪鼻蛇',
          requiredLevel: 30,
          requiredDays: 365,
          requiredItemId: 'evolution_stone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '白化猪鼻蛇',
        ),
      ],
    ),

    // 蓝舌石龙子进化线
    EvolutionLine(
      speciesId: 'blue_tongue_skink',
      speciesName: '蓝舌石龙子',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'blue_tongue_skink_juvenile',
          nextName: '亚成体',
          requiredLevel: 8,
          requiredDays: 60,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'blue_tongue_skink_adult',
          nextName: '成体',
          requiredLevel: 20,
          requiredDays: 300,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'indonesian_blue_tongue',
          nextName: '印尼蓝舌',
          requiredLevel: 40,
          requiredDays: 600,
          requiredItemId: 'evolution_stone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '印尼蓝舌',
        ),
      ],
    ),

    // 高冠变色龙进化线
    EvolutionLine(
      speciesId: 'veiled_chameleon',
      speciesName: '高冠变色龙',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'veiled_chameleon_juvenile',
          nextName: '亚成体',
          requiredLevel: 10,
          requiredDays: 90,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'veiled_chameleon_adult',
          nextName: '成体',
          requiredLevel: 25,
          requiredDays: 365,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'yemen_chameleon',
          nextName: '也门变色龙',
          requiredLevel: 45,
          requiredDays: 730,
          requiredItemId: 'evolution_stone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '也门变色龙',
        ),
      ],
    ),

    // 黄缘闭壳龟进化线
    EvolutionLine(
      speciesId: 'yellow_marginated_box_turtle',
      speciesName: '黄缘闭壳龟',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'yellow_marginated_juvenile',
          nextName: '亚成体',
          requiredLevel: 12,
          requiredDays: 120,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'yellow_marginated_adult',
          nextName: '成体',
          requiredLevel: 30,
          requiredDays: 730,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'golden_marginated',
          nextName: '金缘闭壳龟',
          requiredLevel: 45,
          requiredDays: 1500,
          requiredItemId: 'ink_stone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '金缘闭壳龟',
        ),
      ],
    ),

    // 锯缘摄龟进化线
    EvolutionLine(
      speciesId: 'keeled_box_turtle',
      speciesName: '锯缘摄龟',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'keeled_juvenile',
          nextName: '亚成体',
          requiredLevel: 10,
          requiredDays: 90,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'keeled_adult',
          nextName: '成体',
          requiredLevel: 25,
          requiredDays: 500,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'vietnam_keeled',
          nextName: '越南锯缘',
          requiredLevel: 40,
          requiredDays: 1000,
          requiredItemId: 'evolution_stone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '越南锯缘',
        ),
      ],
    ),

    // 辐射陆龟进化线
    EvolutionLine(
      speciesId: 'radiated_tortoise',
      speciesName: '辐射陆龟',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'radiated_juvenile',
          nextName: '亚成体',
          requiredLevel: 15,
          requiredDays: 180,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'radiated_adult',
          nextName: '成体',
          requiredLevel: 35,
          requiredDays: 730,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'golden_radiated',
          nextName: '金辐陆龟',
          requiredLevel: 50,
          requiredDays: 1500,
          requiredItemId: 'evolution_stone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '金辐陆龟',
        ),
      ],
    ),

    // 赫曼陆龟进化线
    EvolutionLine(
      speciesId: 'hermanns_tortoise',
      speciesName: '赫曼陆龟',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'hermanns_juvenile',
          nextName: '亚成体',
          requiredLevel: 8,
          requiredDays: 60,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'hermanns_adult',
          nextName: '成体',
          requiredLevel: 20,
          requiredDays: 365,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'eastern_hermanns',
          nextName: '东部赫曼',
          requiredLevel: 35,
          requiredDays: 730,
          requiredItemId: 'evolution_stone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '东部赫曼',
        ),
      ],
    ),

    // 角蛙进化线
    EvolutionLine(
      speciesId: 'pacman_frog',
      speciesName: '角蛙',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '蝌蚪',
          nextSpeciesId: 'pacman_juvenile',
          nextName: '幼体',
          requiredLevel: 3,
          requiredDays: 14,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '幼体',
          nextSpeciesId: 'pacman_adult',
          nextName: '成体',
          requiredLevel: 10,
          requiredDays: 90,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'albino_pacman',
          nextName: '白化角蛙',
          requiredLevel: 25,
          requiredDays: 300,
          requiredItemId: 'evolution_stone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '白化角蛙',
        ),
      ],
    ),

    // 蝾螈进化线
    EvolutionLine(
      speciesId: 'axolotl',
      speciesName: '蝾螈',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'axolotl_juvenile',
          nextName: '亚成体',
          requiredLevel: 5,
          requiredDays: 30,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'axolotl_adult',
          nextName: '成体',
          requiredLevel: 15,
          requiredDays: 180,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'golden_axolotl',
          nextName: '金斑蝾螈',
          requiredLevel: 30,
          requiredDays: 365,
          requiredItemId: 'evolution_stone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '金斑蝾螈',
        ),
      ],
    ),

    // 智利红玫瑰蜘蛛进化线
    EvolutionLine(
      speciesId: 'chilean_rose_tarantula',
      speciesName: '智利红玫瑰',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'rose_juvenile',
          nextName: '亚成体',
          requiredLevel: 5,
          requiredDays: 60,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'rose_adult',
          nextName: '成体',
          requiredLevel: 15,
          requiredDays: 180,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'rose_hair',
          nextName: '金毛智利红玫瑰',
          requiredLevel: 30,
          requiredDays: 400,
          requiredItemId: 'evolution_stone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '金毛智利红玫瑰',
        ),
      ],
    ),

    // 墨西哥红膝蜘蛛进化线
    EvolutionLine(
      speciesId: 'mexican_red_knee',
      speciesName: '墨西哥红膝',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'red_knee_juvenile',
          nextName: '亚成体',
          requiredLevel: 8,
          requiredDays: 90,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'red_knee_adult',
          nextName: '成体',
          requiredLevel: 20,
          requiredDays: 300,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'brachypelma',
          nextName: '墨西哥黑玫瑰',
          requiredLevel: 40,
          requiredDays: 600,
          requiredItemId: 'evolution_stone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '墨西哥黑玫瑰',
        ),
      ],
    ),

    // 巴西白膝头进化线
    EvolutionLine(
      speciesId: 'brazilian_white_knee',
      speciesName: '巴西白膝头',
      stages: [
        EvolutionStageConfig(
          stage: EvolutionStage.none,
          name: '幼体',
          nextSpeciesId: 'white_knee_juvenile',
          nextName: '亚成体',
          requiredLevel: 8,
          requiredDays: 90,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.first,
          name: '亚成体',
          nextSpeciesId: 'white_knee_adult',
          nextName: '成体',
          requiredLevel: 20,
          requiredDays: 300,
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.second,
          name: '成体',
          nextSpeciesId: 'aureopilosum',
          nextName: '金丝绒巴西白膝',
          requiredLevel: 40,
          requiredDays: 600,
          requiredItemId: 'evolution_stone',
        ),
        EvolutionStageConfig(
          stage: EvolutionStage.ultimate,
          name: '金丝绒巴西白膝',
        ),
      ],
    ),
  ];

  /// 获取指定物种的进化路线
  static EvolutionLine? getEvolutionLine(String speciesId) {
    try {
      return evolutionLines.firstWhere(
        (line) => line.speciesId == speciesId || line.stages.any((s) => s.nextSpeciesId == speciesId),
      );
    } catch (e) {
      return null;
    }
  }

  /// 获取当前进化阶段配置
  static EvolutionStageConfig? getCurrentStage(EvolutionLine line, EvolutionStage stage) {
    try {
      return line.stages.firstWhere((s) => s.stage == stage);
    } catch (e) {
      return null;
    }
  }

  /// 获取下一阶段配置
  static EvolutionStageConfig? getNextStage(EvolutionLine line, EvolutionStage currentStage) {
    final currentIndex = line.stages.indexWhere((s) => s.stage == currentStage);
    if (currentIndex == -1 || currentIndex >= line.stages.length - 1) {
      return null;
    }
    return line.stages[currentIndex + 1];
  }

  /// 检查是否满足进化条件
  static bool canEvolve(ElectronicPet pet, EvolutionLine line) {
    final currentStage = getCurrentStage(line, pet.evolutionStage);
    if (currentStage == null) return false;

    final nextStage = getNextStage(line, pet.evolutionStage);
    if (nextStage == null) return false;

    final ageDays = pet.getAgeDays();
    final hasLevel = pet.level >= nextStage.requiredLevel;
    final hasAge = ageDays >= nextStage.requiredDays;
    final hasItem = nextStage.requiredItemId == null ||
        pet.inventoryItemIds.contains(nextStage.requiredItemId);

    return hasLevel && hasAge && hasItem;
  }
}
