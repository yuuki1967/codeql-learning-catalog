---
layout: workshop-overview
title: Introduction
course_number: LDF-204
banner: banner-code-graph-shield.png
octicon: package
toc: false
---

## イントロダクション

このワークショップでは、配列のインデックスと確保したサイズの分析と関連性について注目します。-配列の範囲外へのアクセスの簡単なケースを紹介します。

次のコードの抜粋は、範囲外アクセスが起こる例です。

```cpp
char* buffer = malloc(10);
buffer[9] = 'a'; // ok
buffer[10] = 'b'; // out-of-bounds
```

もうちょっと複雑な場合:

```cpp
char* buffer;
if(rand() == 1) {
    buffer = malloc(10);
}
else {
    buffer = malloc(11);
}
size_t index = 0;
if(rand() == 1) {
    index = 10;
}
buffer[index]; // potentially out-of-bounds depending on control-flow
```

別のケース（本ワークショップではカバーしていません）

```cpp
int elements[5];
for (int i = 0; i <= 5; ++i) {
    elements[i] = 0;
}
```

これらの問題を見つけるためには、上限、下限を追跡する分析を実装することができます。そして、誤検知を削減するためのデータフロー分析、どこでバッファーオーバーフローが起きているのかを検出するロジックを入れることができます。
