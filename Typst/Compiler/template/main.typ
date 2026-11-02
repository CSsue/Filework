#import "../lib.typ": *
// #page(
//   margin: (x: 0cm, y: 0cm),  // 封面单独设置边距
//   header: none,  // 封面页不需要页眉
//   footer: none,  // 封面页不需要页码
//   {
//     image("cover.pdf", width: 100%)
//   }
// )


// #figure(
// image("./assets/实验箱构成2.png", width: 90%, height: 35%),
// caption: [实验箱硬件构成图],
// )

#show: project.with(
  title: "编译原理上机实验报告",
  subtitle: "课题：DBMS的设计与实现",
  author: "作者：张书语",
  date: auto,
  // abstract: [
  //   本文档展示了 EasyPaper 模板的主要功能，包括题目框、解答框、三线表格、数学公式等学术组件。
  // ],
  // keywords: ("Typst", "模板", "学术写作"),
)


= 上机任务与目标

== 实验任务

设计并实现一个DBMS原型系统，可以接受基本的SQL语句，对其进行词法分析、语法分析，然后解释执行SQL语句，完成对数据库文件的相应操作，实现DBMS的基本功能。


== 实验目标

1. 加深编译原理基础知识的理解：词法分析、语法分析、语法制导翻译等。
2. 加深相关基础知识的理解：数据库系统、数据结构、操作系统等。
3. 培养分析和解决问题的能力：通过设计和实现DBMS原型系统，锻炼分析问题、设计解决方案、编写代码实现的能力。


== 基本功能要求

1. 词法分析：能够正确识别SQL语句中的关键字、标识符、常量等基本元素。
2. 语法分析：能够正确解析SQL语句的结构，构建相应的语法树。
3. 语义分析：能够进行基本的语义检查，如表是否存在、字段是否存在等。
4. 解释执行：能够根据解析结果执行相应的数据库操作，如创建表、插入数据、查询数据等。
5. 拓展功能（可选）：支持更多的SQL语句类型，如更新、删除等；支持主键约束；支持索引等性能优化功能。

= 实验环境

- 操作系统：Linux Ubuntu 24.04
- 开发工具：Visual Studio Code、GCC编译器
- 词法分析工具：Flex
- 语法分析工具：Bison
- 数据库文件：使用简单的文本文件或二进制文件来存储数据库数据，设计相应的数据结构进行管理。

#problem[
  本人PC的操作系统环境是Linux Ubuntu 24.04，默认支持Flex和Bison工具，可以直接使用命令行进行编译和运行。同时，相比于Lex和Yacc，Flex和Bison提供了更现代化的功能，适合进行DBMS系统的设计与实现，因此本次实验选择了Flex和Bison作为词法分析和语法分析的工具。

]



= 实验原理

== 词法分析

词法分析是编译过程中的第一阶段，负责将源代码转换成一系列的记号（tokens）。在DBMS的设计与实现中，词法分析器需要识别SQL语句中的关键字（如SELECT、INSERT等）、标识符（如表名、字段名等）、常量（如字符串、数字等）以及其他符号（如逗号、括号等）。通过使用Flex工具，可以定义相应的正则表达式来匹配这些元素，并生成一个词法分析器。

下面代码展示识别单词的过程，能够识别输入中的"hello"和"world"两个单词，并输出相应的提示信息。证明了词法分析器能够正确识别输入中的关键字。

```c
%{
#include <stdio.h>
%}

%%
hello   { printf("识别到: hello\n"); }
world   { printf("识别到: world\n"); }
.       { /* 忽略 */ }
\n      { /* 忽略 */ }
%%

int main() {
    printf("请输入文字:\n");
    yylex();
    return 0;
}

int yywrap() {
    return 1;
}

```


运行结果如下：
#figure(
  image("./assets/1.png"),
  caption: [识别单词],
) <fig:example>


下面代码展示了分析记号流的过程，定义了三个记号常量（TOKEN_HELLO、TOKEN_WORLD和TOKEN_OTHER），分别对应识别到的"hello"、"world"和其他输入。当用户输入文本时，词法分析器会返回相应的记号，并输出其数值。


```c
%{
#include <stdio.h>

/* 定义记号常量 */
#define TOKEN_HELLO  1
#define TOKEN_WORLD  2
#define TOKEN_OTHER  3
%}



%%
hello   { return TOKEN_HELLO; }
world   { return TOKEN_WORLD; }
.       { return TOKEN_OTHER; }
\n      { /* 忽略换行 */ }
%%

int main() {
    int token;
    printf("请输入文字，按 Ctrl+D 结束:\n");

    while ((token = yylex()) != 0) {
        printf("返回记号: %d\n", token);
    }
    return 0;
}

int yywrap() {
    return 1;
}

```

运行结果如下：
#figure(
  image("./assets/2.png"),
  caption: [分析记号流],
) <fig:example>

下面代码展示了一个更为完整的词法分析器，能够识别SQL语句中的关键字、标识符、整数和字符串等元素，并返回相应的记号。

```c
%{
#include "sql.tab.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

extern int yylineno;
%}

%option noyywrap
%option yylineno
%option case-insensitive

WHITESPACE      [ \t\n]+
IDENTIFIER      [a-zA-Z_][a-zA-Z0-9_]*
INTEGER         [0-9]+
STRING          '[^'\n]*'

%%
{WHITESPACE}    { }
"CREATE"        { return CREATE; }
"DATABASE"      { return DATABASE; }
"DATABASES"     { return DATABASES; }
"USE"           { return USE; }
"TABLE"         { return TABLE; }
"SHOW"          { return SHOW; }
"TABLES"        { return TABLES; }
"INSERT"        { return INSERT; }
"INTO"          { return INTO; }
"VALUES"        { return VALUES; }
"SELECT"        { return SELECT; }
"FROM"          { return FROM; }
"UPDATE"        { return UPDATE; }
"SET"           { return SET; }
"DELETE"        { return DELETE; }
"DROP"          { return DROP; }
"EXIT"          { return EXIT; }
"INT"           { return INT; }
"CHAR"          { return CHAR; }
"WHERE"         { return WHERE; }
";"             { return ';'; }
","             { return ','; }
"("             { return '('; }
")"             { return ')'; }
"="             { return '='; }
"*"             { return '*'; }
{IDENTIFIER}    { yylval.str = strdup(yytext); return IDENTIFIER; }
{INTEGER}       { yylval.num = atoi(yytext); return INTEGER; }
{STRING}        { yylval.str = strdup(yytext); return STRING; }
.               { fprintf(stderr, "第%d行: 未知字符 '%s'\n", yylineno, yytext); }
%%

```

代码运行结果在语法分析中一并展示。



== 语法分析

语法分析是编译过程中的第二阶段，负责将词法分析器生成的记号序列转换成一个抽象语法树（AST）。在DBMS的设计与实现中，语法分析器需要根据SQL语句的语法规则来解析输入的记号序列，并构建相应的语法树。通过使用Bison工具，可以定义相应的上下文无关文法来描述SQL语句的结构，并生成一个语法分析器。


下面代码展示了一个语法分析器的分析过程，能够解析SQL语句的结构，并构建相应的语法树。在代码中定义了SQL语句的语法规则，并在每个规则的动作部分调用相应的函数来执行数据库操作。

```c
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "database.h"
#include "parser.h"

extern int yylex();
extern int yylineno;
void yyerror(const char *s);
%}

%union {
    int num;
    char *str;
    struct TempColumn {
        char *name;
        int type;
        int length;
    } col;
    struct TempColList {
        struct TempColumn *cols;
        int count;
    } col_list;
    struct ValueList {
        char **values;
        int count;
    } val_list;
}

%token CREATE DATABASE USE TABLE SHOW TABLES DATABASES
%token INSERT INTO VALUES SELECT FROM
%token UPDATE SET DELETE DROP
%token EXIT INT CHAR WHERE
%token <str> IDENTIFIER STRING
%token <num> INTEGER

%type <col> column_def
%type <col_list> column_def_list
%type <val_list> value_list

%%

program:
        statement
        | program statement
        ;

statement:
        create_database_stmt ';'
        | use_database_stmt ';'
        | drop_database_stmt ';'
        | show_databases_stmt ';'
        | create_table_stmt ';'
        | show_tables_stmt ';'
        | drop_table_stmt ';'
        | insert_stmt ';'
        | select_stmt ';'
        | exit_stmt ';'
        ;

create_database_stmt:
        CREATE DATABASE IDENTIFIER
        {
            create_database($3);
            free($3);
        }
        ;

use_database_stmt:
        USE DATABASE IDENTIFIER
        {
            use_database($3);
            free($3);
        }
        ;

drop_database_stmt:
        DROP DATABASE IDENTIFIER
        {
            drop_database($3);
            free($3);
        }
        ;

show_databases_stmt:
        SHOW DATABASES
        {
            show_databases();
        }
        ;

create_table_stmt:
        CREATE TABLE IDENTIFIER '(' column_def_list ')'
        {
            Column *cols = malloc(sizeof(Column) * $5.count);
            for (int i = 0; i < $5.count; i++) {
                cols[i].name = $5.cols[i].name;
                cols[i].type = $5.cols[i].type;
                cols[i].length = $5.cols[i].length;
            }
            create_table($3, cols, $5.count);
            free($5.cols);
            free($3);
        }
        ;

column_def_list:
        column_def
        {
            $$.cols = malloc(sizeof(struct TempColumn));
            $$.cols[0] = $1;
            $$.count = 1;
        }
        | column_def_list ',' column_def
        {
            $$.cols = realloc($1.cols, sizeof(struct TempColumn) * ($1.count + 1));
            $$.cols[$1.count] = $3;
            $$.count = $1.count + 1;
        }
        ;

column_def:
        IDENTIFIER INT
        {
            $$.name = $1;
            $$.type = 0;
            $$.length = 0;
        }
        | IDENTIFIER CHAR '(' INTEGER ')'
        {
            $$.name = $1;
            $$.type = 1;
            $$.length = $4;
        }
        ;

show_tables_stmt:
        SHOW TABLES
        {
            show_tables();
        }
        ;

drop_table_stmt:
        DROP TABLE IDENTIFIER
        {
            drop_table($3);
            free($3);
        }
        ;

insert_stmt:
        INSERT INTO IDENTIFIER VALUES '(' value_list ')'
        {
            insert_into($3, $6.values, $6.count);
            free($6.values);
            free($3);
        }
        ;

value_list:
        STRING
        {
            $$.values = malloc(sizeof(char*));
            $$.values[0] = $1;
            $$.count = 1;
        }
        | value_list ',' STRING
        {
            $$.values = realloc($1.values, sizeof(char*) * ($1.count + 1));
            $$.values[$1.count] = $3;
            $$.count = $1.count + 1;
        }
        | INTEGER
        {
            char buf[32];
            sprintf(buf, "%d", $1);
            $$.values = malloc(sizeof(char*));
            $$.values[0] = strdup(buf);
            $$.count = 1;
        }
        | value_list ',' INTEGER
        {
            char buf[32];
            sprintf(buf, "%d", $3);
            $$.values = realloc($1.values, sizeof(char*) * ($1.count + 1));
            $$.values[$1.count] = strdup(buf);
            $$.count = $1.count + 1;
        }
        ;

select_stmt:
        SELECT '*' FROM IDENTIFIER
        {
            select_from($4, "*", NULL, NULL, NULL);
            free($4);
        }
        ;

exit_stmt:
        EXIT
        {
            printf("再见！\n");
            exit(0);
        }
        ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "第%d行: 语法错误: %s\n", yylineno, s);
}

```


前述词法分析和语法分析的代码共同构成了DBMS系统的前两阶段，能够正确识别输入的SQL语句，并构建相应的语法树，为后续的语义分析和解释执行阶段做好准备。代码运行结果如下：
运行结果如下：
#figure(
  image("./assets/3.png"),
  caption: [测试DBMS系统的词法分析和语法分析],
) <fig:example>

== 语义分析

语义分析是编译过程中的第三阶段，负责检查语法分析器生成的抽象语法树是否符合语言的语义规则。在DBMS的设计与实现中，语义分析器需要进行基本的语义检查，如表是否存在、字段是否存在、数据类型是否匹配等。通过在Bison中定义相应的语义规则，可以实现对SQL语句的语义分析。


一般来说，语义分析器会在语法分析器生成的抽象语法树上进行遍历，检查每个节点是否符合相应的语义规则，并在发现错误时输出相应的错误信息。通过测试该语义分析器，可以验证其是否能够正确检查输入的SQL语句的语义规则，为后续的解释执行阶段做好准备。

本次实验中，语义分析的代码与语法分析的代码结合在一起，在每个语法规则的动作部分调用相应的函数来执行数据库操作，并在这些函数中进行相应的语义检查。通过测试DBMS系统的词法分析、语法分析和语义分析，可以验证其是否能够正确识别输入的SQL语句，并检查其语义规则。

具体代码前文已经实现，此处不再赘述。

#problem[
  编译器在实际实现过程中，只能检测静态语义错误，如表是否存在、字段是否存在、数据类型是否匹配等，而无法检测动态语义错误，如运行时的内存访问错误、死锁等。

]

== 语法制导翻译

语法制导翻译是编译过程中的第四阶段，负责根据语法分析器生成的抽象语法树来生成目标代码。在DBMS的设计与实现中，语法制导翻译器需要根据解析结果执行相应的数据库操作，如创建表、插入数据、查询数据等。通过在Bison中定义相应的语法制导翻译规则，可以实现对SQL语句的解释执行。

事实上，语法制导翻译器的代码也与语法分析器的代码结合在一起，在每个语法规则的动作部分调用相应的函数来执行数据库操作。

== 数据库的核心实现部分

数据库的核心实现部分主要包括数据库文件的管理、数据结构的设计以及相应的数据库操作函数的实现。在DBMS系统中，数据库文件可以使用简单的文本文件或二进制文件来存储数据库数据，而数据结构则需要设计相应的数据结构来管理这些数据。

下面代码实现了DBMS系统的核心功能，包括数据库文件的管理、数据结构的设计以及相应的数据库操作函数的实现。


1. 数据库文件的管理：通过创建和删除数据库目录来管理数据库文件，并使用相应的函数来加载和保存表结构和数据。

```c
void load_tables(void) {
    if (current_db[0] == '\0') return;
    char *db_path = get_db_path();
    DIR *dir = opendir(db_path);
    if (!dir) return;
    struct dirent *entry;
    while ((entry = readdir(dir)) != NULL) {
        char *ext = strstr(entry->d_name, ".tbl");
        if (!ext) continue;
        *ext = '\0';
        char *filepath = get_table_path(entry->d_name, "tbl");
        FILE *fp = fopen(filepath, "rb");
        if (!fp) continue;
        Table *t = &tables[table_count];
        t->name = strdup(entry->d_name);
        t->row_count = 0;
        t->primary_key_col = -1;
        fread(&t->col_count, sizeof(int), 1, fp);
        for (int i = 0; i < t->col_count; i++) {
            int name_len;
            fread(&name_len, sizeof(int), 1, fp);
            t->columns[i].name = malloc(name_len);
            fread(t->columns[i].name, 1, name_len, fp);
            fread(&t->columns[i].type, sizeof(int), 1, fp);
            fread(&t->columns[i].length, sizeof(int), 1, fp);
            fread(&t->columns[i].is_primary, sizeof(int), 1, fp);
            if (t->columns[i].is_primary) t->primary_key_col = i;
        }
        fclose(fp);
        load_table_data(t);
        table_count++;
    }
    closedir(dir);
}

void save_table(Table *t) {
    if (current_db[0] == '\0') return;
    create_directory(get_db_path());
    char *filename = get_table_path(t->name, "tbl");
    FILE *fp = fopen(filename, "wb");
    if (!fp) return;
    fwrite(&t->col_count, sizeof(int), 1, fp);
    for (int i = 0; i < t->col_count; i++) {
        int name_len = strlen(t->columns[i].name) + 1;
        fwrite(&name_len, sizeof(int), 1, fp);
        fwrite(t->columns[i].name, 1, name_len, fp);
        fwrite(&t->columns[i].type, sizeof(int), 1, fp);
        fwrite(&t->columns[i].length, sizeof(int), 1, fp);
        fwrite(&t->columns[i].is_primary, sizeof(int), 1, fp);
    }
    fclose(fp);
}

void load_table_data(Table *t) {
    char *filename = get_table_path(t->name, "dat");
    FILE *fp = fopen(filename, "r");
    if (!fp) return;
    char line[4096];
    t->row_count = 0;
    while (fgets(line, sizeof(line), fp) && t->row_count < MAX_ROWS) {
        trim_newline(line);
        char *values[MAX_COLUMNS];
        int idx = 0;
        char *token = strtok(line, "|");
        while (token && idx < t->col_count) {
            values[idx++] = strdup(token);
            token = strtok(NULL, "|");
        }
        if (idx == t->col_count) {
            for (int i = 0; i < t->col_count; i++) {
                t->rows[t->row_count].values[i] = values[i];
            }
            t->row_count++;
        }
    }
    fclose(fp);
}

void save_table_data(Table *t) {
    char *filename = get_table_path(t->name, "dat");
    FILE *fp = fopen(filename, "w");
    if (!fp) return;
    for (int i = 0; i < t->row_count; i++) {
        for (int j = 0; j < t->col_count; j++) {
            fprintf(fp, "%s%s", t->rows[i].values[j], (j < t->col_count - 1) ? "|" : "");
        }
        fprintf(fp, "\n");
    }
    fclose(fp);
}

```


2. 表格管理：设计了相应的数据结构来管理表格信息，包括表名、列信息、行数据等，并实现了相应的函数来创建表格、显示表格、删除表格等操作。

#figure(
  image("./assets/4.png"),
  caption: [表格管理的实现],
) <fig:example>


此处仅给出创建表格的代码，其余部分的实现类似。

```c
void create_table(char *name, Column *cols, int col_count) {
    if (current_db[0] == '\0') {
        printf("错误：请先使用 USE DATABASE 选择数据库\n");
        return;
    }
    for (int i = 0; i < table_count; i++) {
        if (strcmp(tables[i].name, name) == 0) {
            printf("错误：表 '%s' 已存在\n", name);
            return;
        }
    }
    Table *t = &tables[table_count];
    t->name = strdup(name);
    t->col_count = col_count;
    t->row_count = 0;
    t->primary_key_col = -1;
    printf("创建表 '%s':\n", name);
    for (int i = 0; i < col_count; i++) {
        t->columns[i].name = strdup(cols[i].name);
        t->columns[i].type = cols[i].type;
        t->columns[i].length = cols[i].length;
        t->columns[i].is_primary = cols[i].is_primary;
        if (cols[i].is_primary) {
            t->primary_key_col = i;
            printf("  列: %s PRIMARY KEY\n", cols[i].name);
        } else {
            printf("  列: %s ", cols[i].name);
            if (cols[i].type == 0) printf("INT\n");
            else printf("CHAR(%d)\n", cols[i].length);
        }
    }
    save_table(t);
    table_count++;
    printf("表 '%s' 创建成功！\n\n", name);
}

```

3. 数据操作：实现了相应的函数来执行数据库操作，如插入数据、查询数据等，并在这些函数中进行相应的语义检查，确保操作的合法性。

#figure(
  image("./assets/5.png"),
  caption: [数据操作的实现],
) <fig:example>

此处仅给出插入数据的代码，其余部分的实现类似。
```c

void insert_into(const char *table_name, char **values, int value_count) {
    Table *t = find_table(table_name);
    if (!t) {
        printf("错误：表 '%s' 不存在\n", table_name);
        return;
    }
    if (value_count != t->col_count) {
        printf("错误：列数不匹配（需要 %d 列，提供了 %d 列）\n", t->col_count, value_count);
        return;
    }
    if (!check_primary_key(t, values)) {
        printf("错误：主键冲突！\n");
        return;
    }
    if (t->row_count >= MAX_ROWS) {
        printf("错误：表已满\n");
        return;
    }
    t->rows[t->row_count].values = malloc(sizeof(char*) * t->col_count);
    for (int i = 0; i < value_count; i++) {
        t->rows[t->row_count].values[i] = strdup(values[i]);
    }
    t->row_count++;
    save_table_data(t);
    printf("插入成功\n");
}
```

4. 拓展功能：主键约束的检查，确保插入数据时不会出现主键冲突。

```c
int check_primary_key(Table *t, char **values) {
    if (t->primary_key_col == -1) return 1;
    char *pk_value = values[t->primary_key_col];
    for (int i = 0; i < t->row_count; i++) {
        if (strcmp(t->rows[i].values[t->primary_key_col], pk_value) == 0) return 0;
    }
    return 1;
}
```

5. 错误处理：在每个数据库操作函数中添加了相应的错误处理逻辑，当发生错误时输出相应的错误信息。

#problem[
  错误处理部分几乎融合在所有代码中，无法单独展示，此处不再额外展示代码。

]

6. 大小写不敏感：在词法分析器中添加了 **%option case-insensitive** 选项，使得SQL语句的关键字大小写不敏感。

== 完整可执行的源程序

#problem[
  完整可执行的源代码项目将以附件形式提供，篇幅有限，此处不再赘述。

]



= 实验结果展示

== 欢迎语展示

#figure(
  image("./assets/6.png"),
  caption: [欢迎语],
) <fig:example>

#problem[
  为便于执行代码，使用makefile来管理编译和运行过程，只需在命令行输入 **make run** 即可编译并运行DBMS系统，看到欢迎语展示。

]
== 大小写不敏感展示

#figure(
  image("./assets/25.png"),
  caption: [大小写不敏感展示],
) <fig:example>


== 数据库操作

=== 创建数据库

创建数据库的结果如下：
#figure(
  image("./assets/7.png", width: 80%),
  caption: [创建数据库],
) <fig:example>


=== 显示数据库
显示数据库的结果如下：
#figure(
  image("./assets/8.png", width: 80%),
  caption: [显示数据库],
) <fig:example>

=== 使用数据库

使用数据库的结果如下：
#figure(
  image("./assets/9.png", width: 80%),
  caption: [使用数据库],
) <fig:example>


=== 删除数据库

删除数据库的结果如下：
#figure(
  image("./assets/10.png"),
  caption: [删除数据库],
) <fig:example>


== 表格操作

=== 创建表格

创建表格的结果如下：
#figure(
  image("./assets/11.png", width: 80%),
  caption: [创建表格],
) <fig:example>

=== 显示表格

显示表格的结果如下：
#figure(
  image("./assets/12.png", width: 80%),
  caption: [显示表格],
) <fig:example>

=== 删除表格

删除表格的结果如下：
#figure(
  image("./assets/26.png"),
  caption: [删除表格],
) <fig:example>

== 数据操作

=== 插入数据

插入数据的结果如下：
#figure(
  image("./assets/13.png"),
  caption: [插入数据],
) <fig:example>

=== 查询数据

查询所有数据的结果如下：
#figure(
  image("./assets/14.png"),
  caption: [查询所有数据],
) <fig:example>

有条件查询的结果如下：
#figure(
  image("./assets/15.png", width: 100%),
  caption: [有条件查询],
) <fig:example>

where条件查询的结果如下：
#figure(
  image("./assets/16.png"),
  caption: [where条件查询1],
) <fig:example>

#figure(
  image("./assets/17.png"),
  caption: [where条件查询2],
) <fig:example>

=== 更新数据
更新数据前后的结果如下：
#figure(
  image("./assets/17.png"),
  caption: [更新数据],
) <fig:example>


=== 删除数据

删除数据前后的结果如下：
#figure(
  image("./assets/18.png", width: 100%),
  caption: [删除数据],
) <fig:example>

== 主键约束检查

主键约束检查的结果如下：
#figure(
  image("./assets/20.png", width: 100%),
  caption: [主键约束检查],
) <fig:example>

结果显示，当尝试插入主键冲突的数据时，系统能够正确检测到并输出相应的错误信息，且不会插入重复数据，证明了主键约束检查功能的正确性。


== 退出提示

#figure(
  image("./assets/28.png", width: 100%),
  caption: [退出提示],
) <fig:example>

== 错误处理展示

=== 词法错误

缺少括号：
#figure(
  image("./assets/21.png", width: 100%),
  caption: [词法错误1],
) <fig:example>

缺少分号，会在下一行命令输入后显示错误：
#figure(
  image("./assets/22.png", width: 100%),
  caption: [词法错误2],
) <fig:example>

=== 表不存在

#figure(
  image("./assets/23.png", width: 100%),
  caption: [表不存在],
) <fig:example>

=== 数据库不存在

#figure(
  image("./assets/24.png", width: 100%),
  caption: [数据库不存在],
) <fig:example>




= 问题分析

在第二次进入DBMS系统是出现了段错误（Segmentation Fault），发生在 USE DATABASE a; 命令执行时。问题是因为数据库 a 目录下存在损坏的 .tbl 文件。
#figure(
  image("./assets/error1.png", width: 100%),
  caption: [存储错误],
) <fig:example>

需要删除该损坏的 .tbl 文件后重新创建表格，才能正常使用数据库 a。
#problem[
  后续代码的维护中需要添加对数据库文件的完整性检查，避免因损坏的文件导致系统崩溃。

]

= 心得体会

这个实验做下来，我最真实的感受就是“看懂了和做出来完全是两码事”。上课听老师讲词法分析、语法分析、语法制导翻译，觉得概念都很清晰，但真正上手写Flex和Bison的时候，才发现连一个简单的正则表达式都可能写错。

但在完成实验的过程中，从零开始搭一个系统的实验，比我预想的要有价值得多。以前做作业大多是改改已有代码，或者填空补全，这次是从头写词法规则、语法规则、数据结构、文件存储，整个流程走了一遍，才明白编译器的前端和后端是怎么衔接的。在语法制导翻译的实现过程中，在sql.y里写语义动作，解析SQL的同时调用database.c的函数去操作文件，这种设计模式在真实的数据库和编译器中确实能用得上。

通过这个实验，我不仅加深了对编译原理的理解，还锻炼了分析和解决问题的能力。虽然过程中遇到了不少困难，但最终能够实现一个基本功能的DBMS系统，还是非常有成就感的。希望以后能有机会继续深入学习数据库系统和编译器设计，做出更复杂、更高效的系统来。

本次实验感谢老师的耐心指导和助教老师的辛苦付出，最后也感谢同学对我的帮助和支持，让我能够顺利完成这个实验。



