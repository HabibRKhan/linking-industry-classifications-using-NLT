# Linking industrial classifications using NLT
The International Standard Industrial Classification of All Economic Activities (ISIC) is the international reference classification of productive activities. Its main purpose is to provide a set of activity categories that can be utilized for the collection and reporting of statistics according to such activities. Since the adoption of the original version of ISIC in 1948, the majority of countries around the world have used ISIC as their national activity classification or have developed national classifications derived from ISIC. ISIC has therefore provided guidance to countries in developing national activity classifications and has become an important tool for comparing statistical data on economic activities at the international level. Wide use has been made of ISIC, both nationally and internationally, in classifying data according to kind of economic activity in the fields of economic and social statistics, such as for statistics on national accounts, demography of enterprises, employment and others. In addition, ISIC is increasingly used for non-statistical purposes.

## Objective
The aim of this project was to map ISIC version 3 (ISIC3) activity descriptions with ISIC4 using natural language processing (NLT). Traditionally, this work was done manually. But it will require a lots of resources (in terms of worker-hours) because there are almost 26,000 ISIC3 activities descriptions to be compared with the ISIC4 descriptions. So NLT was used to make the task easier (by a lot!).

There are 400+ codes in ISIC4 and 300+ in ISIC3 and ISIC3.1. The list of around 26,000 activities (descriptions) for ISIC3 had been previously mapped to ISIC3 codes.

## Steps
### Mapping ISIC4 and ISIC3
Mapping between ISIC3 and ISIC3.1, and between ISIC3.1 and ISIC4 was used to develop a mapping beyween ISIC3 and ISIC4.

### Cleaning
The texts were cleaned to remove new lines (\n) and special characters.

### Separating 1-to-1 matches
Some ISIC4 codes had 1-to-1 matches with ISIC3 codes. These were excluded from further processing since their mapping was already complete and certain. Around 6,000 activities had 1-to-1 matches leaving 20,000 for further analyses.

### Identifying common words
Words in common between the ISIC3 activities, and ISIC4 descriptions and extended descriptions were identified and counted. Common words like "and", "or", "the" were exlcuded from this comparison. Words which have no comparison value in this context such as "services" were also excluded.

Importantly, negation was identified. For example, for ISIC3 activitiy "Blacktop contractor (except roads)", the ISIC4 code with description "Construction of roads and railways" would be flagged as negation because these have a common word which is preceded with "except" or "not" in either.

### Editorial distance
Levenshtein distance between two strings is the minimum number of single-character edits (insertions, deletions or substitutions) required to change one into the other. This distance between the ISIC3 activities description and the ISIC4 full descriptions were calculated as the Levenshtein distance of the set of words in them. A **Proximity** index was defined by diving the number of characters in the activities descriptions by the sum of the Levenshtein distances between the two sets of words. A higher value of the index would indicate a closer match because the denominator would be small compared to the numerator in that case.

## Future improvements
Below points should be considered for future improvements:
- Review of words to be excluded. For example, could we also exlcude "growing" as it appears in many aggricultural activities but seems to have no comparison values?
- Negation didn't work as well as expected. For example, Comparison between ISIC3 Activity:
“Beet, sugar, farming”;
and ISIC4 full description:
“This class includes:- growing of leafy or stem vegetables such as:, artichokes, asparagus, cabbages, cauliflower and broccoli, lettuce and chicory, spinach, other leafy or stem vegetables- growing of fruit bearing vegetables such as:, cucumbers and gherkins, eggplants (aubergines), tomatoes, watermelons, cantaloupes, other melons and fruit-bearing vegetables- growing of root, bulb or tuberous vegetables such as:, carrots, turnips, garlic, onions (incl. shallots), leeks and other alliaceous vegetables, other root, bulb or tuberous vegetables- growing of mushrooms and truffles- growing of vegetable seeds, except beet seeds- growing of sugar beet- growing of other vegetables- growing of roots and tubers such as:, potatoes, sweet potatoes, cassava, yams, other roots and tubers”
would be negative because the script defines negation as presence of common words where in one of the strings it is preceded by “except” or “not”.
In fact, these two correspond.
- Could use of large language models (AI) give us better results?

