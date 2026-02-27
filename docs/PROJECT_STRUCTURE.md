# 9牌-银河往事：工程结构

```
9pai-galaxy-new/
├── project.godot              # Godot项目配置
├── README.md                  # 项目说明
├── docs/                      # 文档目录
│   ├── PROJECT_STRUCTURE.md   # 本文件
│   ├── UI_FLOW.md            # UI流程设计
│   └── DATABASE_SCHEMA.md    # 数据库结构
├── assets/                    # 资源目录
│   ├── images/               # 图片资源
│   │   ├── ui/              # UI元素
│   │   ├── cards/           # 卡牌图片
│   │   ├── characters/      # 角色立绘
│   │   └── backgrounds/     # 背景图
│   ├── audio/                # 音频资源
│   │   ├── bgm/             # 背景音乐
│   │   ├── sfx/             # 音效
│   │   └── voice/           # 语音
│   ├── fonts/                # 字体文件
│   └── animations/           # 动画资源
├── src/                       # 源代码
│   ├── core/                 # 核心系统
│   │   ├── GameManager.gd   # 游戏主管理器
│   │   ├── SaveManager.gd   # 存档管理
│   │   ├── EventBus.gd      # 事件总线
│   │   └── Constants.gd     # 常量定义
│   ├── gameplay/             # 游戏玩法
│   │   ├── RoundManager.gd  # 回合管理
│   │   ├── CardExecutor.gd  # 卡牌执行器
│   │   └── TurnSystem.gd    # 回合系统
│   ├── ui/                   # UI系统
│   │   ├── screens/         # 主屏幕
│   │   │   ├── MainMenu.gd
│   │   │   ├── HostelScreen.gd
│   │   │   ├── GameTableScreen.gd
│   │   │   ├── DialogScreen.gd
│   │   │   └── SettlementScreen.gd
│   │   ├── components/      # UI组件
│   │   │   ├── CardButton.gd
│   │   │   ├── CharacterPanel.gd
│   │   │   ├── NineCardGrid.gd
│   │   │   └── DialogBox.gd
│   │   └── transitions/     # 转场动画
│   ├── data/                 # 数据目录
│   │   ├── cards/           # 卡牌数据
│   │   │   ├── base_cards.json
│   │   │   └── advanced_cards.json
│   │   ├── characters/      # 角色数据
│   │   │   ├── player_data.json
│   │   │   └── npc_data.json
│   │   ├── levels/          # 关卡数据
│   │   │   └── levels.json
│   │   └── configs/         # 配置数据
│   │       ├── game_config.json
│   │       └── ai_config.json
│   ├── cards/                # 卡牌系统
│   │   ├── CardData.gd      # 卡牌数据类
│   │   ├── CardDatabase.gd  # 卡牌数据库
│   │   ├── CardEffect.gd    # 卡牌效果
│   │   └── CardFactory.gd   # 卡牌工厂
│   ├── characters/           # 角色系统
│   │   ├── CharacterData.gd # 角色数据类
│   │   ├── CharacterDB.gd   # 角色数据库
│   │   ├── Player.gd        # 玩家
│   │   └── NPC.gd           # NPC
│   ├── effects/              # 效果系统
│   │   ├── StatusEffect.gd  # 状态效果
│   │   └── EffectProcessor.gd
│   ├── ai/                   # AI系统
│   │   ├── AIBase.gd        # AI基类
│   │   ├── AIDecision.gd    # AI决策
│   │   └── AIPersonality.gd # AI性格
│   └── narrative/            # 叙事系统
│       ├── DialogSystem.gd
│       ├── ClueSystem.gd
│       └── StoryManager.gd
├── tests/                     # 测试目录
│   ├── test_cards.gd
│   ├── test_gameplay.gd
│   └── test_ai.gd
└── export_presets.cfg         # 导出配置
```
