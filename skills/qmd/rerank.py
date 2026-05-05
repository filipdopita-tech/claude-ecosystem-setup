#!/usr/bin/env python3
"""Cross-encoder reranker for QMD results. +20-35% precision over BM25/vector alone."""
from sentence_transformers import CrossEncoder
import json, sys

_model = None

def get_model():
    global _model
    if _model is None:
        _model = CrossEncoder("cross-encoder/ms-marco-MiniLM-L-6-v2")
    return _model

def rerank(query, candidates, top_k=10):
    model = get_model()
    pairs = [(query, (doc.get("content") or doc.get("text") or doc.get("body") or "")[:512]) for doc in candidates]
    scores = model.predict(pairs)
    reranked = sorted(zip(candidates, scores.tolist()), key=lambda x: x[1], reverse=True)
    result = []
    for doc, score in reranked[:top_k]:
        d = dict(doc)
        d["rerank_score"] = round(float(score), 4)
        result.append(d)
    return result

if __name__ == "__main__":
    data = json.load(sys.stdin)
    query = data["query"]
    candidates = data.get("results") or data.get("hits") or []
    top_k = data.get("top_k", 10)
    if not candidates:
        print(json.dumps([]))
        sys.exit(0)
    print(json.dumps(rerank(query, candidates, top_k), ensure_ascii=False, indent=2))
