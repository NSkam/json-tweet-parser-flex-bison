%{ 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define TEXTLEN 140
#define STR_ID_SIZE 100
#define ID_SIZE 100
#define SCR_NAME_SIZE 100

extern int yylex();
extern int yyparse();
extern FILE *yyin;
void yyerror(const char *s);
int str_id[STR_ID_SIZE];
int str_index=0;
int id[ID_SIZE];
int id_index=0;
char* scr_name[SCR_NAME_SIZE];
int scr_name_index=0;
extern int line_number;
char* scr_name_str;
int scr_name_counter=0;

%}
%union{
	unsigned long int ival;
	float fval;
	char *sval;
	char chval;
}

%token TEXT
%token ARRAY
%token STRING
%token NLN
%token QUOT
%token OBLK
%token CBLK
%token COM
%token WS
%token DATE
%token STRINGID
%token CREATE
%token USER
%token IDSTRING
%token ID
%token NAME
%token SCNAME
%token LOCAT
%token URLSTR
%token URL
%token DESCR
%token PLACE
%token ENTI
%token HASH
%token HASHTAG
%token OBRA
%token CBRA
%token URLSSTR
%token UNWOUND
%token TITLE
%token USERMEN
%token TWEETTOK
%token ORMSG
%token RESTAT

%type  <sval> STRING
%type  <ival> ID
%type  <sval> DATE
%type  <sval> URL
%type  <sval> DESCR
%type  <sval> HASHTAG
%type  <sval> ORMSG
%%
tweet_file:
	tweet_file COM NLN tweet 
	| tweet
	| tweet_file COM NLN retweet
	| retweet
	;
retweet:
	OBLK NLN {printf("{\n");}
	TWEETTOK OBLK NLN{printf("\"tweet\": {\n");}
	retweet_original_text NLN{printf("\n");}
	USER OBLK NLN {printf("\t\"user\": {\n\t");}
	screen_name
	NLN CBLK COM NLN{printf("\n\t},\n");}
	RESTAT OBLK NLN {printf("\t\"retweeted_status\": {\n\t\t");}
	text STRING NLN{printf(".\n");}
	USER OBLK NLN {printf("\t\t\"user\": {\n\t\t");}
	screen_name
	retweet_check
	NLN CBLK COM NLN{printf("\n\t\t},\n\t\t");}
	place 
	OBLK NLN CBLK COM NLN ENTI OBLK NLN {printf("{\n\t},\n\t\"entities\": {\n");}
	entities
	CBLK NLN CBLK NLN{printf("\n\t}\n}\n");
			} 
;
entities:
	hashtags 
	COM NLN {printf(",\n");}
	urls 
	user_mentions 
	NLN{printf("\n");}
	|%empty
;
retweet_original_text:
	TEXT QUOT ORMSG QUOT{printf("\t\"text\": \"%s\"",$3);}
;
retweet_check:
	%empty{	for(int i=0;i<scr_name_index-1;i++){
			if(strcmp(scr_name_str,scr_name[i])==0){
					scr_name_counter=1;}}
			if(scr_name_counter==0){yyerror("\nYou can't retweet a tweet that doesn't exist");}
			}
;
tweet:
	OBLK NLN {printf("{\n");}
	created_at 
	COM NLN {printf(",\n");}
	id_str 
	COM NLN {printf(",\n");}
	text 
	COM NLN USER OBLK NLN {printf(",\n\"user\": {\n");}
	complete_id 
	COM NLN {printf(",\n");}
	name 
	COM NLN {printf(",\n");}
	screen_name 
	COM NLN {printf(",\n");}
	location 
	COM NLN {printf(",\n");}
	url 
	COM NLN {printf(",\n");}
	description 
	NLN CBLK COM NLN{printf("\n},\n");}
	place 
	OBLK NLN CBLK COM NLN ENTI OBLK NLN {printf("{\n\t},\n\"entities\": {\n");}
	hashtags 
	COM NLN {printf(",\n");}
	urls 
	user_mentions 
	NLN CBLK NLN CBLK NLN{printf("\n}\n}\n");
			}	 
;
created_at:
	CREATE QUOT DATE QUOT{printf("\"created_at\": \"%s\"",$3);
			}
	|%empty{yyerror("The tweet must contain the created_at field");
			}
;
id_str:
	STRINGID QUOT ID QUOT
		{
		 int id_str_value=$3;
		 for(int i=0;i<STR_ID_SIZE;i++){
			if(id_str_value==str_id[i]){yyerror("This ID already exists");}}
		 str_id[str_index]=id_str_value;
		 str_index++;
			printf("\"id_str\": \"%ld\"",$3);
			}
	|%empty{yyerror("The tweet must contain the ID_string field");
			}
;					
text:
	TEXT QUOT STRING QUOT{if(strlen($3)>TEXTLEN){yyerror("Text length must be less than 140 characters");}
		      else{printf("\"text\": \"%s\"",$3);}
			}
	|%empty{yyerror("The tweet must contain the Text field");
			}
;
complete_id:
	IDSTRING id 
	|%empty{yyerror("The tweet must contain the ID field");
			}
;
id:
	ID
		{int id_value=$1;
		 for(int i=0;i<ID_SIZE;i++){
			if(id_value==id[i]){yyerror("This ID already exists");}}
		 id[id_index]=id_value;
		 id_index++;
		 printf("\t\"id\": %ld",$1);}
;
name:
	NAME QUOT STRING QUOT {printf("\t\"name\": \"%s\"",$3);}
	|%empty{yyerror("The tweet must contain the name field");
			}
;
screen_name:
	SCNAME QUOT STRING QUOT {scr_name_str=$3;
				 scr_name[scr_name_index]=scr_name_str;
				 scr_name_index++;
				 printf("\t\"screen_name\": \"%s\"",$3);
				}
	|%empty{yyerror("The tweet must contain the Screen_name field");
			}
;
location:
	LOCAT QUOT STRING QUOT  {printf("\t\"location\": \"%s\"",$3);}
	|%empty{yyerror("The tweet must contain the location field");
			}
;
url:
	URLSTR QUOT URL QUOT{printf("\t\"url\": \"%s\"",$3);}
	|%empty{yyerror("The tweet must contain the url field");
			}
;
description:
	DESCR QUOT{printf("\t%s\"",$1);}
;
place:
	PLACE {printf("\"place\": ");} placestr 
;
placestr:
	QUOT STRING QUOT{printf("\"%s\"",$2);}
	|%empty
;
hashtags:
	HASH OBRA {printf("\t\"hashtags\": [");} hashtag CBRA{printf("]");}
	|%empty
;
hashtag:
	HASHTAG{printf("%s",$1);}
	|%empty
;
urls:
	URLSSTR	OBRA NLN OBLK NLN {printf("\t\"urls\": [\n\t{\n");}
	url2 
	COM NLN UNWOUND OBLK NLN URLSTR QUOT URL {printf(",\n\t\t\"unwound\": {\n\t\t\t\"url\": \"%s",$15);}
	QUOT COM NLN TITLE QUOT STRING QUOT NLN{printf("\",\n\t\t\t\"title\": \"%s\"\n",$22);}
	CBLK NLN CBLK NLN CBRA COM NLN{printf("\t\t}\n\t}\n],\n");}
	|%empty
;
url2:
	URLSTR QUOT URL QUOT{printf("\t\t\"url\": \"%s\"",$3);}
	|%empty
;
user_mentions:
	USERMEN OBRA {printf("\t\"user_mentions\": [");} 
	mentions CBRA{printf("]");}
	|%empty
;
mentions:
	QUOT STRING QUOT{printf("\"%s\"",$2);}
	|%empty
;
%%

int main(int argc, char** argv)
{
	/*file handler*/
	FILE *testfile=fopen(argv[1],"r");

	if(!testfile){
	printf("cant open file");
	return -1;
}

	yyin = testfile;

	/*parse through*/
	yyparse();
	
	return 0;
}
void yyerror(const char *s){

	printf("%s\n",s);
	printf("There is an error in line %d\n",line_number);
	exit(-1);
}
