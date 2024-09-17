#!/bin/bash

  # --move-call 0x196fcb64b11fd5436b240264ab389e80e0eb7e5c58622813ac4fbd631fe18ed0::voting::
sui client ptb \
  --make-move-vec "<u64>" "[1, 2, 3, 4, 5]" \
  --assign project_ids \
  --make-move-vec "<address>" "[sad-alexandrite, nifty-dichroite, inspiring-euclase, vigorous-phenacite, practical-chrysoberyl]" \
  --assign addresses \
  --assign cap @0x80e5a0ac6050b0f1e30fa5a27a29fdb0c176c2db3ebf41a51d1a8e0fd241c1f6 \
  --assign votes @0x1bb3e18f3d9881c5c8089055ddf796fb142323925dba067022868caad247b623 \
  --move-call 0x196fcb64b11fd5436b240264ab389e80e0eb7e5c58622813ac4fbd631fe18ed0::approval::create_shortlist cap votes project_ids addresses @0x8 \
  --gas-budget 200000000
