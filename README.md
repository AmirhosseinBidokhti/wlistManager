# wlistManager
These scripts are easy solutions for two problems I had with public wordlists I cloned and used for fuzzing.

1. During pentests or bug bounty I usually got lost and frustrated between huge wordlists and repo files I cloned, constantly trying to find the right one and frequently used ones. Copying and hand-picking those files to other directory isn't really good idea since I have to re-copy each time I update and pull the the wordlist repos.

-> Using symbolic links to hand-pick and store some of the frequently used ones yet keeping it at the repo itself

2. Different repos like SecLists and Assetnote might differ in wordlists yet lots of common contextual categories. For example they both have their own wordlist for jsp files, php files, parameters, etc.

-> Being able to hand-pick and merge the ones that are in common in term of context and unique them can allow us to cover more and take advantage of both of them during fuzzing.
