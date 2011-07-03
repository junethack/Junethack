
global_settings
{
    ambient_light 0
}

#declare rng_seed = seed(52);
#declare random_value = rand(rng_seed);

// Returns a random value between 0 and 1
#macro invoke_rng() rand(rng_seed) #end

// Returns a random integer between 0 and x_max-1
#macro random_int(x_max) int(rand(rng_seed) * x_max) #end

// Some nethack monsters
#declare monster_colors = array[233]
#declare monster_symbols = array[233]

// The following lines are automatically generated from pino databases
// fire ant
#declare monster_colors[0] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[0] = "a";
// giant ant
#declare monster_colors[1] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[1] = "a";
// soldier ant
#declare monster_colors[2] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[2] = "a";
// giant beetle
#declare monster_colors[3] = pigment{ rgb<0.2, 0.2, 0.2> };
#declare monster_symbols[3] = "a";
// queen bee
#declare monster_colors[4] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[4] = "a";
// killer bee
#declare monster_colors[5] = pigment{ rgb<1, 1, 0> };
#declare monster_symbols[5] = "a";
// ghost
#declare monster_colors[6] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[6] = " ";
// shade
#declare monster_colors[7] = pigment{ rgb<0.2, 0.2, 0.2> };
#declare monster_symbols[7] = " ";
// pyrolisk
#declare monster_colors[8] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[8] = "c";
// cockatrice
#declare monster_colors[9] = pigment{ rgb<1, 1, 0> };
#declare monster_symbols[9] = "c";
// chickatrice
#declare monster_colors[10] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[10] = "c";
// acid blob
#declare monster_colors[11] = pigment{ rgb<0, 0.5, 0> };
#declare monster_symbols[11] = "b";
// quivering blob
#declare monster_colors[12] = pigment{ rgb<1, 1, 1> };
#declare monster_symbols[12] = "b";
// gelatinous cube
#declare monster_colors[13] = pigment{ rgb<0, 0.5, 0.5> };
#declare monster_symbols[13] = "b";
// flaming sphere
#declare monster_colors[14] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[14] = "e";
// shocking sphere
#declare monster_colors[15] = pigment{ rgb<0, 0, 1> };
#declare monster_symbols[15] = "e";
// freezing sphere
#declare monster_colors[16] = pigment{ rgb<1, 1, 1> };
#declare monster_symbols[16] = "e";
// gas spore
#declare monster_colors[17] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[17] = "e";
// floating eye
#declare monster_colors[18] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[18] = "e";
// hell hound
#declare monster_colors[19] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[19] = "d";
// warg
#declare monster_colors[20] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[20] = "d";
// winter wolf
#declare monster_colors[21] = pigment{ rgb<0, 0.5, 0.5> };
#declare monster_symbols[21] = "d";
// large dog
#declare monster_colors[22] = pigment{ rgb<1, 1, 1> };
#declare monster_symbols[22] = "d";
// dingo
#declare monster_colors[23] = pigment{ rgb<1, 1, 0> };
#declare monster_symbols[23] = "d";
// gargoyle
#declare monster_colors[24] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[24] = "g";
// gremlin
#declare monster_colors[25] = pigment{ rgb<0, 0.5, 0> };
#declare monster_symbols[25] = "g";
// winged gargoyle
#declare monster_colors[26] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[26] = "g";
// panther
#declare monster_colors[27] = pigment{ rgb<0.2, 0.2, 0.2> };
#declare monster_symbols[27] = "f";
// large cat
#declare monster_colors[28] = pigment{ rgb<1, 1, 1> };
#declare monster_symbols[28] = "f";
// jaguar
#declare monster_colors[29] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[29] = "f";
// tiger
#declare monster_colors[30] = pigment{ rgb<1, 1, 0> };
#declare monster_symbols[30] = "f";
// lynx
#declare monster_colors[31] = pigment{ rgb<0, 0.5, 0.5> };
#declare monster_symbols[31] = "f";
// imp
#declare monster_colors[32] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[32] = "i";
// homunculus
#declare monster_colors[33] = pigment{ rgb<0, 0.5, 0> };
#declare monster_symbols[33] = "i";
// lemure
#declare monster_colors[34] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[34] = "i";
// quasit
#declare monster_colors[35] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[35] = "i";
// tengu
#declare monster_colors[36] = pigment{ rgb<0, 0.5, 0.5> };
#declare monster_symbols[36] = "i";
// dwarf
#declare monster_colors[37] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[37] = "h";
// hobbit
#declare monster_colors[38] = pigment{ rgb<0, 0.5, 0> };
#declare monster_symbols[38] = "h";
// bugbear
#declare monster_colors[39] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[39] = "h";
// dwarf lord
#declare monster_colors[40] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[40] = "h";
// master mind flayer
#declare monster_colors[41] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[41] = "h";
// large kobold
#declare monster_colors[42] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[42] = "k";
// kobold lord
#declare monster_colors[43] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[43] = "k";
// kobold shaman
#declare monster_colors[44] = pigment{ rgb<0, 0, 1> };
#declare monster_symbols[44] = "k";
// kobold
#declare monster_colors[45] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[45] = "k";
// spotted jelly
#declare monster_colors[46] = pigment{ rgb<0, 0.5, 0> };
#declare monster_symbols[46] = "j";
// ochre jelly
#declare monster_colors[47] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[47] = "j";
// blue jelly
#declare monster_colors[48] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[48] = "j";
// large mimic
#declare monster_colors[49] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[49] = "m";
// small mimic
#declare monster_colors[50] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[50] = "m";
// giant mimic
#declare monster_colors[51] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[51] = "m";
// leprechaun
#declare monster_colors[52] = pigment{ rgb<0, 0.5, 0> };
#declare monster_symbols[52] = "l";
// orc
#declare monster_colors[53] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[53] = "o";
// hobgoblin
#declare monster_colors[54] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[54] = "o";
// Mordor orc
#declare monster_colors[55] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[55] = "o";
// orc-captain
#declare monster_colors[56] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[56] = "o";
// goblin
#declare monster_colors[57] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[57] = "o";
// Uruk-hai
#declare monster_colors[58] = pigment{ rgb<0.2, 0.2, 0.2> };
#declare monster_symbols[58] = "o";
// orc shaman
#declare monster_colors[59] = pigment{ rgb<0, 0, 1> };
#declare monster_symbols[59] = "o";
// hill orc
#declare monster_colors[60] = pigment{ rgb<1, 1, 0> };
#declare monster_symbols[60] = "o";
// wood nymph
#declare monster_colors[61] = pigment{ rgb<0, 0.5, 0> };
#declare monster_symbols[61] = "n";
// mountain nymph
#declare monster_colors[62] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[62] = "n";
// water nymph
#declare monster_colors[63] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[63] = "n";
// leocrotta
#declare monster_colors[64] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[64] = "q";
// rothe
#declare monster_colors[65] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[65] = "q";
// wumpus
#declare monster_colors[66] = pigment{ rgb<0, 0.5, 0.5> };
#declare monster_symbols[66] = "q";
// baluchitherium
#declare monster_colors[67] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[67] = "q";
// mastodon
#declare monster_colors[68] = pigment{ rgb<0.2, 0.2, 0.2> };
#declare monster_symbols[68] = "q";
// iron piercer
#declare monster_colors[69] = pigment{ rgb<0, 0.5, 0.5> };
#declare monster_symbols[69] = "p";
// rock piercer
#declare monster_colors[70] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[70] = "p";
// glass piercer
#declare monster_colors[71] = pigment{ rgb<1, 1, 1> };
#declare monster_symbols[71] = "p";
// centipede
#declare monster_colors[72] = pigment{ rgb<1, 1, 0> };
#declare monster_symbols[72] = "s";
// scorpion
#declare monster_colors[73] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[73] = "s";
// cave spider
#declare monster_colors[74] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[74] = "s";
// Scorpius
#declare monster_colors[75] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[75] = "s";
// woodchuck
#declare monster_colors[76] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[76] = "r";
// rock mole
#declare monster_colors[77] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[77] = "r";
// black unicorn
#declare monster_colors[78] = pigment{ rgb<0.2, 0.2, 0.2> };
#declare monster_symbols[78] = "u";
// warhorse
#declare monster_colors[79] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[79] = "u";
// gray unicorn
#declare monster_colors[80] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[80] = "u";
// white unicorn
#declare monster_colors[81] = pigment{ rgb<1, 1, 1> };
#declare monster_symbols[81] = "u";
// lurker above
#declare monster_colors[82] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[82] = "t";
// trapper
#declare monster_colors[83] = pigment{ rgb<0, 0.5, 0> };
#declare monster_symbols[83] = "t";
// long worm
#declare monster_colors[84] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[84] = "w";
// purple worm
#declare monster_colors[85] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[85] = "w";
// ice vortex
#declare monster_colors[86] = pigment{ rgb<0, 0.5, 0.5> };
#declare monster_symbols[86] = "v";
// fog cloud
#declare monster_colors[87] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[87] = "v";
// dust vortex
#declare monster_colors[88] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[88] = "v";
// energy vortex
#declare monster_colors[89] = pigment{ rgb<0, 0, 1> };
#declare monster_symbols[89] = "v";
// steam vortex
#declare monster_colors[90] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[90] = "v";
// fire vortex
#declare monster_colors[91] = pigment{ rgb<1, 1, 0> };
#declare monster_symbols[91] = "v";
// yellow light
#declare monster_colors[92] = pigment{ rgb<1, 1, 0> };
#declare monster_symbols[92] = "y";
// black light
#declare monster_colors[93] = pigment{ rgb<0.2, 0.2, 0.2> };
#declare monster_symbols[93] = "y";
// xan
#declare monster_colors[94] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[94] = "x";
// grid bug
#declare monster_colors[95] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[95] = "x";
// kraken
#declare monster_colors[96] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[96] = ";";
// electric eel
#declare monster_colors[97] = pigment{ rgb<0, 0, 1> };
#declare monster_symbols[97] = ";";
// giant eel
#declare monster_colors[98] = pigment{ rgb<0, 0.5, 0.5> };
#declare monster_symbols[98] = ";";
// shark
#declare monster_colors[99] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[99] = ";";
// jellyfish
#declare monster_colors[100] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[100] = ";";
// zruty
#declare monster_colors[101] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[101] = "z";
// ki-rin
#declare monster_colors[102] = pigment{ rgb<1, 1, 0> };
#declare monster_symbols[102] = "A";
// couatl
#declare monster_colors[103] = pigment{ rgb<0, 0.5, 0> };
#declare monster_symbols[103] = "A";
// Angel
#declare monster_colors[104] = pigment{ rgb<1, 1, 1> };
#declare monster_symbols[104] = "A";
// Archon
#declare monster_colors[105] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[105] = "A";
// sergeant
#declare monster_colors[106] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[106] = "@";
// Neferet the Green
#declare monster_colors[107] = pigment{ rgb<0, 0.5, 0> };
#declare monster_symbols[107] = "@";
// wererat
#declare monster_colors[108] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[108] = "@";
// captain
#declare monster_colors[109] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[109] = "@";
// Dark One
#declare monster_colors[110] = pigment{ rgb<0.2, 0.2, 0.2> };
#declare monster_symbols[110] = "@";
// watchman
#declare monster_colors[111] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[111] = "@";
// apprentice
#declare monster_colors[112] = pigment{ rgb<1, 1, 1> };
#declare monster_symbols[112] = "@";
// Medusa
#declare monster_colors[113] = pigment{ rgb<0, 1, 0> };
#declare monster_symbols[113] = "@";
// Oracle
#declare monster_colors[114] = pigment{ rgb<0, 0, 1> };
#declare monster_symbols[114] = "@";
// werewolf
#declare monster_colors[115] = pigment{ rgb<1, 0, 0> };
#declare monster_symbols[115] = "@";
// Ashikaga Takauji
#declare monster_colors[116] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[116] = "@";
// plains centaur
#declare monster_colors[117] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[117] = "C";
// forest centaur
#declare monster_colors[118] = pigment{ rgb<0, 0.5, 0> };
#declare monster_symbols[118] = "C";
// mountain centaur
#declare monster_colors[119] = pigment{ rgb<0, 0.5, 0.5> };
#declare monster_symbols[119] = "C";
// giant bat
#declare monster_colors[120] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[120] = "B";
// bat
#declare monster_colors[121] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[121] = "B";
// vampire bat
#declare monster_colors[122] = pigment{ rgb<0.2, 0.2, 0.2> };
#declare monster_symbols[122] = "B";
// air elemental
#declare monster_colors[123] = pigment{ rgb<0, 0.5, 0.5> };
#declare monster_symbols[123] = "E";
// stalker
#declare monster_colors[124] = pigment{ rgb<1, 1, 1> };
#declare monster_symbols[124] = "E";
// earth elemental
#declare monster_colors[125] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[125] = "E";
// water elemental
#declare monster_colors[126] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[126] = "E";
// fire elemental
#declare monster_colors[127] = pigment{ rgb<1, 1, 0> };
#declare monster_symbols[127] = "E";
// Ixoth
#declare monster_colors[128] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[128] = "D";
// green dragon
#declare monster_colors[129] = pigment{ rgb<0, 0.5, 0> };
#declare monster_symbols[129] = "D";
// blue dragon
#declare monster_colors[130] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[130] = "D";
// Chromatic Dragon
#declare monster_colors[131] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[131] = "D";
// gray dragon
#declare monster_colors[132] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[132] = "D";
// orange dragon
#declare monster_colors[133] = pigment{ rgb<1, 0, 0> };
#declare monster_symbols[133] = "D";
// yellow dragon
#declare monster_colors[134] = pigment{ rgb<1, 1, 0> };
#declare monster_symbols[134] = "D";
// silver dragon
#declare monster_colors[135] = pigment{ rgb<0, 1, 1> };
#declare monster_symbols[135] = "D";
// white dragon
#declare monster_colors[136] = pigment{ rgb<1, 1, 1> };
#declare monster_symbols[136] = "D";
// black dragon
#declare monster_colors[137] = pigment{ rgb<0.2, 0.2, 0.2> };
#declare monster_symbols[137] = "D";
// gnome
#declare monster_colors[138] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[138] = "G";
// gnome king
#declare monster_colors[139] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[139] = "G";
// gnome lord
#declare monster_colors[140] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[140] = "G";
// gnomish wizard
#declare monster_colors[141] = pigment{ rgb<0, 0, 1> };
#declare monster_symbols[141] = "G";
// red mold
#declare monster_colors[142] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[142] = "F";
// green mold
#declare monster_colors[143] = pigment{ rgb<0, 0.5, 0> };
#declare monster_symbols[143] = "F";
// brown mold
#declare monster_colors[144] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[144] = "F";
// yellow mold
#declare monster_colors[145] = pigment{ rgb<1, 1, 0> };
#declare monster_symbols[145] = "F";
// lichen
#declare monster_colors[146] = pigment{ rgb<0, 1, 0> };
#declare monster_symbols[146] = "F";
// violet fungus
#declare monster_colors[147] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[147] = "F";
// giant
#declare monster_colors[148] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[148] = "H";
// hill giant
#declare monster_colors[149] = pigment{ rgb<0, 0.5, 0.5> };
#declare monster_symbols[149] = "H";
// Cyclops
#declare monster_colors[150] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[150] = "H";
// frost giant
#declare monster_colors[151] = pigment{ rgb<1, 1, 1> };
#declare monster_symbols[151] = "H";
// minotaur
#declare monster_colors[152] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[152] = "H";
// storm giant
#declare monster_colors[153] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[153] = "H";
// Lord Surtur
#declare monster_colors[154] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[154] = "H";
// fire giant
#declare monster_colors[155] = pigment{ rgb<1, 1, 0> };
#declare monster_symbols[155] = "H";
// Kop Kaptain
#declare monster_colors[156] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[156] = "K";
// Kop Lieutenant
#declare monster_colors[157] = pigment{ rgb<0, 0.5, 0.5> };
#declare monster_symbols[157] = "K";
// Kop Sergeant
#declare monster_colors[158] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[158] = "K";
// jabberwock
#declare monster_colors[159] = pigment{ rgb<1, 0, 0> };
#declare monster_symbols[159] = "J";
// dwarf mummy
#declare monster_colors[160] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[160] = "M";
// elf mummy
#declare monster_colors[161] = pigment{ rgb<0, 0.5, 0> };
#declare monster_symbols[161] = "M";
// kobold mummy
#declare monster_colors[162] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[162] = "M";
// ettin mummy
#declare monster_colors[163] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[163] = "M";
// giant mummy
#declare monster_colors[164] = pigment{ rgb<0, 0.5, 0.5> };
#declare monster_symbols[164] = "M";
// human mummy
#declare monster_colors[165] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[165] = "M";
// demilich
#declare monster_colors[166] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[166] = "L";
// lich
#declare monster_colors[167] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[167] = "L";
// arch-lich
#declare monster_colors[168] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[168] = "L";
// ogre lord
#declare monster_colors[169] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[169] = "O";
// ogre
#declare monster_colors[170] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[170] = "O";
// ogre king
#declare monster_colors[171] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[171] = "O";
// red naga
#declare monster_colors[172] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[172] = "N";
// guardian naga
#declare monster_colors[173] = pigment{ rgb<0, 0.5, 0> };
#declare monster_symbols[173] = "N";
// golden naga
#declare monster_colors[174] = pigment{ rgb<1, 1, 0> };
#declare monster_symbols[174] = "N";
// black naga
#declare monster_colors[175] = pigment{ rgb<0.2, 0.2, 0.2> };
#declare monster_symbols[175] = "N";
// quantum mechanic
#declare monster_colors[176] = pigment{ rgb<0, 0.5, 0.5> };
#declare monster_symbols[176] = "Q";
// brown pudding
#declare monster_colors[177] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[177] = "P";
// green slime
#declare monster_colors[178] = pigment{ rgb<0, 0.5, 0> };
#declare monster_symbols[178] = "P";
// gray ooze
#declare monster_colors[179] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[179] = "P";
// black pudding
#declare monster_colors[180] = pigment{ rgb<0.2, 0.2, 0.2> };
#declare monster_symbols[180] = "P";
// water moccasin
#declare monster_colors[181] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[181] = "S";
// garter snake
#declare monster_colors[182] = pigment{ rgb<0, 0.5, 0> };
#declare monster_symbols[182] = "S";
// snake
#declare monster_colors[183] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[183] = "S";
// cobra
#declare monster_colors[184] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[184] = "S";
// python
#declare monster_colors[185] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[185] = "S";
// rust monster
#declare monster_colors[186] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[186] = "R";
// disenchanter
#declare monster_colors[187] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[187] = "R";
// umber hulk
#declare monster_colors[188] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[188] = "U";
// rock troll
#declare monster_colors[189] = pigment{ rgb<0, 0.5, 0.5> };
#declare monster_symbols[189] = "T";
// ice troll
#declare monster_colors[190] = pigment{ rgb<1, 1, 1> };
#declare monster_symbols[190] = "T";
// troll
#declare monster_colors[191] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[191] = "T";
// water troll
#declare monster_colors[192] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[192] = "T";
// Olog-hai
#declare monster_colors[193] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[193] = "T";
// wraith
#declare monster_colors[194] = pigment{ rgb<0.2, 0.2, 0.2> };
#declare monster_symbols[194] = "W";
// barrow wight
#declare monster_colors[195] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[195] = "W";
// Nazgul
#declare monster_colors[196] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[196] = "W";
// vampire
#declare monster_colors[197] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[197] = "V";
// vampire lord
#declare monster_colors[198] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[198] = "V";
// Vlad the Impaler
#declare monster_colors[199] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[199] = "V";
// owlbear
#declare monster_colors[200] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[200] = "Y";
// carnivorous ape
#declare monster_colors[201] = pigment{ rgb<0.2, 0.2, 0.2> };
#declare monster_symbols[201] = "Y";
// sasquatch
#declare monster_colors[202] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[202] = "Y";
// yeti
#declare monster_colors[203] = pigment{ rgb<1, 1, 1> };
#declare monster_symbols[203] = "Y";
// xorn
#declare monster_colors[204] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[204] = "X";
// dwarf zombie
#declare monster_colors[205] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[205] = "Z";
// elf zombie
#declare monster_colors[206] = pigment{ rgb<0, 0.5, 0> };
#declare monster_symbols[206] = "Z";
// gnome zombie
#declare monster_colors[207] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[207] = "Z";
// ettin zombie
#declare monster_colors[208] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[208] = "Z";
// giant zombie
#declare monster_colors[209] = pigment{ rgb<0, 0.5, 0.5> };
#declare monster_symbols[209] = "Z";
// orc zombie
#declare monster_colors[210] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[210] = "Z";
// skeleton
#declare monster_colors[211] = pigment{ rgb<1, 1, 1> };
#declare monster_symbols[211] = "Z";
// ghoul
#declare monster_colors[212] = pigment{ rgb<0.2, 0.2, 0.2> };
#declare monster_symbols[212] = "Z";
// long worm tail
#declare monster_colors[213] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[213] = "5";
// newt
#declare monster_colors[214] = pigment{ rgb<1, 1, 0> };
#declare monster_symbols[214] = ":";
// lizard
#declare monster_colors[215] = pigment{ rgb<0, 0.5, 0> };
#declare monster_symbols[215] = ":";
// salamander
#declare monster_colors[216] = pigment{ rgb<1, 0, 0> };
#declare monster_symbols[216] = ":";
// crocodile
#declare monster_colors[217] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[217] = ":";
// Nalzok
#declare monster_colors[218] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[218] = "&";
// horned devil
#declare monster_colors[219] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[219] = "&";
// water demon
#declare monster_colors[220] = pigment{ rgb<0, 0, 0.5> };
#declare monster_symbols[220] = "&";
// Famine
#declare monster_colors[221] = pigment{ rgb<0.5, 0, 0.5> };
#declare monster_symbols[221] = "&";
// sandestin
#declare monster_colors[222] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[222] = "&";
// djinni
#declare monster_colors[223] = pigment{ rgb<1, 1, 0> };
#declare monster_symbols[223] = "&";
// Juiblex
#declare monster_colors[224] = pigment{ rgb<0, 1, 0> };
#declare monster_symbols[224] = "&";
// ice devil
#declare monster_colors[225] = pigment{ rgb<1, 1, 1> };
#declare monster_symbols[225] = "&";
// mail daemon
#declare monster_colors[226] = pigment{ rgb<0, 0, 1> };
#declare monster_symbols[226] = "&";
// flesh golem
#declare monster_colors[227] = pigment{ rgb<0.5, 0, 0> };
#declare monster_symbols[227] = "'";
// gold golem
#declare monster_colors[228] = pigment{ rgb<1, 1, 0> };
#declare monster_symbols[228] = "'";
// stone golem
#declare monster_colors[229] = pigment{ rgb<0.5, 0.5, 0.5> };
#declare monster_symbols[229] = "'";
// paper golem
#declare monster_colors[230] = pigment{ rgb<1, 1, 1> };
#declare monster_symbols[230] = "'";
// clay golem
#declare monster_colors[231] = pigment{ rgb<0.5, 0.5, 0> };
#declare monster_symbols[231] = "'";
// iron golem
#declare monster_colors[232] = pigment{ rgb<0, 0.5, 0.5> };
#declare monster_symbols[232] = "'";
// End of automatically generated monster lines

#macro rng_monster() random_int(233) #end

#declare player_x = 0;
#declare player_y = -20;
#declare player_radius = 7;

#declare stop = 0;
#declare x_pos = -100;
#declare y_pos = -400;
#while (stop = 0)

    #declare mid = rng_monster();
    #declare x_pos_f = x_pos + invoke_rng()*0.5;
    #declare y_pos_f = y_pos + invoke_rng()*0.5;

    #if (vlength(<x_pos_f, y_pos_f> - <player_x, player_y>) >= player_radius)
    text
    {
        ttf "font.ttf" monster_symbols[mid]
        0.1, 0
        pigment { monster_colors[mid] }
        // rotate <0, 180, 0>
        rotate <90, 0, 0>
        translate <x_pos + invoke_rng()*0.5, 0.2, y_pos + invoke_rng()*0.5>
    }
    #end

    #declare x_pos = x_pos + 1;
    #if (x_pos > 200)
        #declare x_pos = -200;
        #declare y_pos = y_pos + 1;
        #if (y_pos > 5)
            #declare stop = 1;
        #end
    #end
    
#end

text
{
    ttf "font.ttf" "@"
    0.1, 0
    pigment { rgb<1, 1, 1> }
    finish { ambient 1 }
    rotate <0, 180, 0>
    translate <player_x, 1.0, player_y>
    no_shadow
}

camera 
{
 right x*1920/1080
 location <0, 20, -60>
 look_at <0, 0, -60>
}

light_source
{
 <0, 10, -60>, rgb <3, 3, 3>
 fade_power 1
 fade_distance 10
}

