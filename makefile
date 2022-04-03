
bison -d tweetbison.y

flex tweetlex.l

g++ tweet_parser.tab.c lex.yy.c -lfl -o tweet_parser.exe

