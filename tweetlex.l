%{ 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "erotima2.tab.h"

extern YYSTYPE yylval;
extern int yylex();
void yyerror(const char *s);
int line_number=1;
char* print_str[1000];

%}

quot		\"
string		([ a-zA-Z0-9.!@#$%^&*_+=\;:/?<>()-]|"\\"[a-zA-Z0-9.!@#$%^&*_+=\;:/?<>()-])+
real_num	[-]?[0-9]+("."[0-9]+)?([eE][+-]?[0-9]+)?
array		"["{string}(","{string})*"]"
dayname		"Mon"|"Tue"|"Wed"|"Thu"|"Fri"|"Sat"|"Sun"
month		"Jan"|"Feb"|"Mar"|"Apr"|"May"|"Jun"|"Jul"|"Aug"|"Sep"|"Oct"|"Nov"|"Dec"
day		[0-2][1-9]|[1-3][0]|31
timestamp	([0-1][0-9]|2[0-3])":"([0-5][0-9]|60)":"([0-5][0-9]|60)
year		[0-2][0-9][0-9][0-9]
date		{dayname}[ ]{month}[ ]{day}[ ]{timestamp}[ ]{year}
tweet		{string}
id		[0-9]+
url		"https:""\\/""\\/"[a-zA-Z0-9]+(("."[a-zA-Z0-9]+)+)?"."[a-z]+"\\/"?(([a-zA-Z0-9%:?=_!-]+("."[a-z]+)?"\\/"?)+)?
description	"\"description\": \""([ a-zA-Z0-9.!@#$%^&*_+=\;:/?<>(),-]|"\\"[a-zA-Z0-9.!@#$%^&*_+=\;:/?<>(),-])+
hashtag		"#"[ a-zA-Z0-9.!@#$%^&*_+=\;:/?<>()-]+
re_original_msg "RT @"{string}" "{string}

%%
("\"created_at\": ")			{return CREATE;}
{date}					{yylval.sval = strdup(yytext);
					 return DATE;}
("\"id_str\": ")			{return STRINGID;}
("\"text\": ")				{return TEXT;}
("\"user\": ")				{return USER;}
("\"id\": ")				{return IDSTRING;}
("\"name\": ")				{return NAME;}
("\"screen_name\": ")			{return SCNAME;}
("\"location\": ")			{return LOCAT;}
("\"url\": ")				{return URLSTR;}
("\"tweet\": ")				{return TWEETTOK;}
{url}					{yylval.sval = strdup(yytext);
					return URL;}
("\"place\": ")				{return PLACE;}
("\"entities\": ")			{return ENTI;}
("\"hashtags\": ")			{return HASH;}
("\"urls\": ")				{return URLSSTR;}
{hashtag}				{yylval.sval = strdup(yytext);
					 return HASHTAG;}
("\"unwound\": ")			{return UNWOUND;}
("\"title\": ")				{return TITLE;}
("\"user_mentions\": ")			{return USERMEN;}
{description}				{yylval.sval = strdup(yytext);
					return DESCR;}
{re_original_msg}			{yylval.sval = strdup(yytext);
					return ORMSG;}
("\"retweeted_status\": ")			{return RESTAT;}
{id}					{yylval.ival = atol(yytext);
					return ID;}
{string}				{yylval.sval = strdup(yytext);
		 			 return STRING;}
{array}					{return ARRAY;}
[\t]					{}
\n					{++line_number;
					return NLN;}
{quot}					{return QUOT;}
"{"					{return OBLK;}
"}"					{return CBLK;}
"["					{return OBRA;}
"]"					{return CBRA;}
,					{return COM;}
.					{;}
%%



