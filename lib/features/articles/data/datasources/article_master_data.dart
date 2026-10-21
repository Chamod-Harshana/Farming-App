import '../../domain/models/article_model.dart';

/// Central database catalog of technical crop guides and advisory articles provided by the App.
class ArticleMasterData {
  ArticleMasterData._();

  static List<ArticleModel> get masterArticles => [
        // ==================== GUAVA CROP GUIDE (පේර වගාව) ====================
        ArticleModel(
          id: 'guide_guava_01',
          cropId: 'guava_02',
          title: 'Guava Cultivation Technical Guide',
          titleSi: 'පේර වගාව පිළිබඳ සම්පූර්ණ උපදෙස් මාලාව',
          subtitle: 'Healthy Plants • Better Harvests',
          subtitleSi: 'සරු වගාවෙන් - ඉහළ අස්වැන්නක්',
          coverImagePath: 'assets/images/guava/cover.jpg',
          category: 'Fruit Crop Advisory',
          categorySi: 'පළතුරු වගා මාර්ගෝපදේශ',
          readTimeMinutes: 8,
          author: 'Department of Agriculture & Farming Advisory Team',
          sections: [
            const ArticleSection(
              title: 'Overview & Introduction',
              titleSi: 'හැඳින්වීම සහ පසුබිම',
              content:
                  'Guava (Psidium guajava) is one of the most profitable fruit crops in Sri Lanka. It can be easily cultivated in almost any climatic zone across the island, providing a high year-round harvest income.',
              contentSi:
                  'පේර (Psidium guajava) යනු ශ්‍රී ලංකාවේ ඕනෑම දේශගුණික කලාපයක පහසුවෙන් වගා කළ හැකි, වසර පුරා ඉහළ ආදායමක් ලබා ගත හැකි ප්‍රධාන පළතුරු වගාවකි. අධික විටමින් C අන්තර්ගතය සහ වගාවේ පවතින ශක්තිමත් බව නිසා අලුතින් වගා ආරම්භ කරන ගොවීන්ට පවා සාර්ථක ප්‍රතිඵල ලබාගත හැක.',
              highlightBoxSi:
                  '💡 පේර වගාව යනු මුල් මාස 12-18 ඇතුළත අස්වැන්න ලබාදෙන, අවම නඩත්තුවකින් ඉහළ වෙළඳපොළ ඉල්ලුමක් සපයන ලාභදායී පළතුරු වගාවකි.',
            ),
            const ArticleSection(
              title: '1. Recommended Varieties',
              titleSi: '1. ශ්‍රී ලංකාවට සුදුසු ප්‍රධාන පේර වර්ග (Recommended Varieties)',
              imagePath: 'assets/images/guava/varieties.jpg',
              bulletPointsSi: [
                'පබ්ලික් (Publique) / ලංකා ජම්බු පේර: ගෙඩි ප්‍රමාණයෙන් විශාලයි, මදය සුදු පැහැතියි. වෙළඳපොළේ ඉහළ ඉල්ලුමක් පවතී.',
                'කිලෝ පේර (Kilo Guava): එක් ගෙඩියක් ග්‍රෑම් 500 – 800 (කිලෝ 1 දක්වා) බර වේ. මදය තද ගතියෙන් යුක්තයි.',
                'රතු මද පේර (Red Flesh / Pink Guava): විටමින් C සහ ප්‍රතිඔක්සිකාරක ඉහළයි. මදය රෝස/රතු පැහැතියි.',
                'ලැබීමා (Labeema): කෘෂිකර්ම දෙපාර්තමේන්තුව මගින් නිර්දේශිත, ගුණාත්මක බවින් ඉහළ වර්ගයකි.',
                'Bangkok Apple Guava: කුඩා පඳුරු ලෙස වැවෙන, ඉක්මනින් ඵල දරන වර්ගයකි.',
              ],
              highlightBoxSi:
                  '📌 වෙළඳපොළට සැපයීමට "පබ්ලික්" සහ "කිලෝ පේර" වඩාත් සුදුසු වන අතර, පෝෂණීය අගය සහ ජූස් නිෂ්පාදනය සඳහා "රතු මද පේර" වැඩි ඉල්ලුමක් ගනී.',
            ),
            const ArticleSection(
              title: '2. Soil & Climate Requirements',
              titleSi: '2. පස සහ දේශගුණික අවශ්‍යතා (Soil & Climate)',
              bulletPointsSi: [
                'දේශගුණය: මුහුදු මට්ටමේ සිට මීටර් 1500 දක්වා ප්‍රදේශ වල සාර්ථකව වැවේ. තද වියළි කාලගුණයට මෙන්ම සාමාන්‍ය වර්ෂාපතනයටද ඔරොත්තු දේ.',
                'පස: හොඳින් ජලය බැසයන ලෝම් හෝ වැලි ලෝම් පස වඩාත් සුදුසුය. පසෙහි ජලය රඳා නොසිටිය යුතුය.',
                'පස් වල pH අගය: 5.5 – 7.5 අතර පැවතිය යුතුය.',
              ],
            ),
            const ArticleSection(
              title: '3. Land Preparation & Spacing',
              titleSi: '3. වගාව ආරම්භ කිරීම සහ පරතරය (Land Preparation & Spacing)',
              imagePath: 'assets/images/guava/spacing.jpg',
              contentSi:
                  'නිසි ලෙස බිම සකස් කර වලවල් කැපීම මගින් මුල් පද්ධතිය ශක්තිමත්ව පැතිරීමටත්, ගසේ ඉක්මන් වර්ධනයටත් පදනම සැකසේ.',
              bulletPointsSi: [
                'පස සකස් කිරීම: ඉඩම හොඳින් ශුද්ධ කර තට්ටු ක්‍රමයට හෝ තලයට සකස් කරගන්න.',
                'වලක ප්‍රමාණය: දිග, පළල සහ ගැඹුර අඩි 2 x 2 x 2 (සෙ.මී. 60 x 60 x 60) වන පරිදි වලවල් කපන්න.',
                'පස් වෙන් කිරීම: වලවල් කැපීමේදී මතුපිට පස සහ යට පස වෙන් වෙන්ව තබන්න.',
                'වලවල් පිරවීම: වලවල් පිරවීමේදී මතුපිට පස් සමග හොඳින් දිරාපත් වූ කොම්පෝස්ට් හෝ ගොම පොහොර කිලෝග්‍රෑම් 10-15 ක් මිශ්‍ර කර වල පුරවන්න.',
                'සාමාන්‍ය පරතරය: අඩි 12 x 12 (මීටර් 3.5 x 3.5) – අක්කරයකට පැළ 300ක් පමණ.',
                'අධි-සාන්ද්‍ර වගා ක්‍රමය (High Density Planting): අඩි 8 x 8 හෝ අඩි 10 x 10 – අක්කරයකට පැළ 450-600ක් පමණ.',
              ],
            ),
            const ArticleSection(
              title: '4. Fertilizer Management',
              titleSi: '4. පොහොර යෙදීම (Fertilizer Management)',
              contentSi:
                  'පේර ගසට වසරකට දෙවතාවක් (වර්ෂා කාලය ආරම්භයේදී) පොහොර යෙදීම සුදුසුය.',
              bulletPointsSi: [
                'කාබනික පොහොර: ගසකට වසරකට කොම්පෝස්ට් හෝ ගොම පොහොර කිලෝග්‍රෑම් 10 – 20 බැගින් ගසේ වියන මායිම දිගේ යොදන්න.',
                'වර්ධන අවධිය (අවුරුදු 1-2): NPK (යුරියා, ත්‍රිත්ව සුපර් පොස්ෆේට්, මියුරියේට් ඔෆ් පොටෑෂ්) 15:15:15 මිශ්‍රණය ගසකට ග්‍රෑම් 250 - 500 බැගින් වසරකට දෙවතාවක්.',
                'ඵල දරන අවධිය (අවුරුදු 2 සිට උඩට): පොටෑසියම් (K) වැඩි පොහොර මිශ්‍රණයක් යෙදීමෙන් ගෙඩි වල පැණි රසය සහ ගුණාත්මක භාවය වැඩි වේ.',
              ],
              highlightBoxSi:
                  '🌿 පොහොර යෙදීමේදී ගසේ කඳට සෙ.මී 30ක් ඈතින් ගසේ වියන මායිමට (Canopy drip line) යටින් වළල්ලක් ලෙස යොදා පස් වලින් වසන්න.',
            ),
            const ArticleSection(
              title: '5. Maintenance, Pruning & Fruit Bagging',
              titleSi: '5. නඩත්තුව, කප්පාදුව සහ ආරක්ෂාව (Pruning & Care)',
              imagePath: 'assets/images/guava/care.jpg',
              bulletPointsSi: [
                'ජල සම්පාදනය: පැළ සිටුවා මුල් මාස 3 තුළ දින 2කට වරක් ජලය සැපයිය යුතුය. ඵල හටගන්නා කාලයේදී නිසි ලෙස ජලය දීමෙන් ගෙඩි හැලීම පාලනය වේ.',
                'අග්‍රස්ථ කුඩින්න කැපීම (Top cutting): සිටුවා මීටර් 1ක් පමණ උස ගිය පසු අග්‍රස්ථ කුඩින්න කපා අතු විහිදීමට ඉඩ හරින්න.',
                'අතු කප්පාදුව: රෝගී, වියළි සහ ඇතුළට වර්ධනය වන අතු කපා ඉවත් කරන්න.',
                'අංකුර ඉවත් කිරීම: බිම් මට්ටමේ සිට අඩි 1.5ක් දක්වා කඳේ එන අංකුර (Suckers) කපා දමන්න.',
                'ගෙඩි කවර දැමීම (Fruit Bagging): ගෙඩිය දෙහි ගෙඩියක ප්‍රමාණයට ආ පසු නොවන (Non-woven) කවර හෝ පොලිතීන් බෑග් වලින් වැසීම මගින් මැස්සන්ගෙන් සහ සතුන්ගෙන් ආරක්ෂා කර ගත හැක.',
              ],
            ),
            const ArticleSection(
              title: '6. Major Diseases & Pest Control',
              titleSi: '6. ප්‍රධාන රෝග සහ පාලනය (Diseases & Control)',
              bulletPointsSi: [
                '1. පේර පිටි මකුණා (Mealybug): පත්‍ර යට, අතු වල සහ ගෙඩි මත සුදු පැහැති පිටි වැනි කෘමීන් සිටීම. කොහොඹ තෙල් මිශ්‍රණය (Neem oil) හෝ සබන් වතුර ඉසින්න. දැඩි හානි වලදී Imidacloprid යොදන්න.',
                '2. පළතුරු මැස්සා (Fruit Fly): ගෙඩි පණුවන් ගැසීම සහ ඉදුණු පසු කුණු වීම. ගෙඩි කුඩා කාලයේදීම කවර (Bags) දැමීම සහ ෆෙරමෝන් උගුල් (Pheromone traps) භාවිත කරන්න.',
                '3. අන්ත්‍රැක්නෝස් රෝගය (Anthracnose): පත්‍ර සහ ගෙඩි මත තද දුඹුරු/කළු පැහැති ලප ඇතිවීම. කප්පාදුව මගින් සුර්යාලෝකය ලබාදෙන්න; කොපර් ඔක්සික්ලෝරයිඩ් හෝ Mancozeb දිලීර නාශක යොදන්න.',
              ],
            ),
            const ArticleSection(
              title: '7. Harvesting & Post-Harvest Care',
              titleSi: '7. අස්වැන්න නෙලීම (Harvesting)',
              imagePath: 'assets/images/guava/harvest.jpg',
              bulletPointsSi: [
                'බද්ධ පැළ සිටුවා මාස 12 - 18ක් ඇතුළත මුල් අස්වැන්න ලබාගත හැක.',
                'ගෙඩියේ තද කොළ පැහැය ළා කොළ හෝ කහ පැහැයට හැරෙන විට නෙලාගන්න.',
                'උදෑසන කාලයේ නෙලාගැනීමෙන් පලතුරේ නවුම් බව වැඩි කාලයක් තබාගත හැක.',
              ],
              highlightBoxSi:
                  '☀️ උදෑසන පිනි සිඳුණු පසු ගෙඩිය නටුවත් සමඟ පරිස්සමින් කඩා ගැනීමෙන් ගෙඩියට හානි වීම වැළකේ.',
            ),
            const ArticleSection(
              title: '8. Pro Farming Tips & Market Potential',
              titleSi: '8. අධික අස්වැන්නක් සහ ඉහළ ආදායමක් සඳහා විශේෂ කෘෂි උපදෙස්',
              bulletPointsSi: [
                'වසුන් යෙදීම (Mulching): වියළි කාලවලදී ගස වටා පිදුරු හෝ වියළි කොළ යෙදීමෙන් පසෙහි තෙතමනය රැකගත හැක.',
                'වෙළඳපොළ ආදායම: අධි-සාන්ද්‍ර පේර වගාවකින් වසරකට අක්කරයකින් කිලෝග්‍රෑම් 8,000 - 12,000 ක අස්වැන්නක් සහ ලක්ෂ 15කට වැඩි ශුද්ධ ආදායමක් ලැබිය හැක.',
                'පෝෂණීය වටිනාකම: පේර දොඩම් මෙන් 4 ගුණයක විටමින් C වලින් යුක්ත වන අතර ප්‍රතිශක්තිකරණය ඉහළ නංවයි.',
              ],
            ),
          ],
        ),

        // Additional crop guides for Catalog richness
        ArticleModel(
          id: 'guide_mango_02',
          cropId: 'mango_01',
          title: 'Mango Cultivation Advisory',
          titleSi: 'අඹ වගාව පිළිබඳ සාර්ථක මාර්ගෝපදේශය',
          subtitle: 'High Yield Tropical Farming',
          subtitleSi: 'ඉහළ අස්වැන්නක් සඳහා අඹ වගා උපදෙස්',
          coverImagePath: 'assets/images/crops/mango.png',
          category: 'Fruit Crop Advisory',
          categorySi: 'පළතුරු වගා මාර්ගෝපදේශ',
          readTimeMinutes: 6,
          author: 'Govi Mithuru Agriculture Team',
          sections: [
            const ArticleSection(
              title: 'Overview',
              titleSi: 'හැඳින්වීම',
              contentSi: 'ටොම් ඊජුවාට් (TJC) සහ කාර්තකොලොම්බන් අඹ වගාවන් සඳහා ශ්‍රී ලංකාවේ වියළි හා මැද කලාප ඉතා යෝග්‍ය වේ.',
              bulletPointsSi: [
                'පරතරය: මීටර් 8 x 8 (අඩි 25 x 25) පරතරයට සිටුවන්න.',
                'ජල පාලනය: මල් හටගන්නා කාලයේදී ජල සම්පාදනය සීමා කිරීමෙන් මල් වැටීම පාලනය වේ.',
                'කප්පාදුව: අස්වැන්න නෙලූ වහාම වියළි අතු සහ අභ්‍යන්තර අතු කපා දැමීම අත්‍යවශ්‍ය වේ.',
              ],
            ),
          ],
        ),

        ArticleModel(
          id: 'guide_tomato_03',
          cropId: 'tomato_14',
          title: 'Tomato Farming Best Practices',
          titleSi: 'තක්කාලි වගාවේ රෝග පාලනය සහ අස්වැන්න වැඩි කිරීම',
          subtitle: 'Vegetable Care & Pest Defense',
          subtitleSi: 'එළවළු වගාව සහ පලිබෝධ පාලනය',
          coverImagePath: 'assets/images/crops/tomato.png',
          category: 'Vegetable Crop Advisory',
          categorySi: 'එළවළු වගා මාර්ගෝපදේශ',
          readTimeMinutes: 5,
          author: 'Govi Mithuru Agriculture Team',
          sections: [
            const ArticleSection(
              title: 'Overview',
              titleSi: 'හැඳින්වීම',
              contentSi: 'තක්කාලි යනු ඉතා ඉක්මනින් අස්වැන්න ලබාගත හැකි එළවළු වගාවකි.',
              bulletPointsSi: [
                'පරතරය: පේළි අතර සෙ.මී. 60 සහ පැළ අතර සෙ.මී. 45.',
                'මැස්සන් පාලනය: කෝඩියල් දිලීර නාශක සහ නිසි පරතරය තබා ගැනීම.',
              ],
            ),
          ],
        ),
      ];

  static ArticleModel get guavaArticle => masterArticles.firstWhere((a) => a.id == 'guide_guava_01');
}
