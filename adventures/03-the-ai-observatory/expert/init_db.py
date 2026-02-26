import os
import json
from typing import List

from qdrant_client import QdrantClient
from qdrant_client.http import models
from langchain_qdrant import QdrantVectorStore
from langchain_community.embeddings import FakeEmbeddings
from langchain_core.documents import Document

# ==================================================================================
# 💾 ART Memory Initializer
# ==================================================================================
# Loads navigation logs and entertainment scripts into Qdrant.
# ==================================================================================

# Configuration
DATA_DIR = "data"
COLLECTION_NAME = "art_memory"
QDRANT_HOST = "localhost"
QDRANT_PORT = 30108

def load_documents() -> List[Document]:
    """Loads navigation logs and entertainment scripts into memory."""
    documents = []

    # Load Navigation Logs
    try:
        with open(os.path.join(DATA_DIR, "navigation_logs.json"), "r") as f:
            nav_data = json.load(f)
            for item in nav_data:
                documents.append(Document(page_content=item["content"], metadata=item["metadata"]))
    except FileNotFoundError:
        print(f"⚠️ Warning: navigation_logs.json not found in {DATA_DIR}")

    # Load Sanctuary Moon Scripts
    try:
        with open(os.path.join(DATA_DIR, "sanctuary_moon_scripts.json"), "r") as f:
            ent_data = json.load(f)
            for item in ent_data:
                documents.append(Document(page_content=item["content"], metadata=item["metadata"]))
    except FileNotFoundError:
        print(f"⚠️ Warning: sanctuary_moon_scripts.json not found in {DATA_DIR}")

    print(f"📚 Loaded {len(documents)} memory fragments from disk.")
    return documents

def initialize_vector_db(documents: List[Document]):
    """Initializes the vector database with ART's memory."""
    print(f"🔌 Connecting to Qdrant at {QDRANT_HOST}:{QDRANT_PORT}...")

    # Connect to the external Qdrant service
    client = QdrantClient(host=QDRANT_HOST, port=QDRANT_PORT)

    # Reset the collection to ensure a clean state
    try:
        client.delete_collection(collection_name=COLLECTION_NAME)
        print("🧹 Memory wiped (collection deleted).")
    except Exception:
        print("ℹ️ Collection did not exist, creating new one.")

    # We use FakeEmbeddings for simplicity (no API key needed)
    embeddings = FakeEmbeddings(size=4096)

    # Create the vector store and add documents
    vector_store = QdrantVectorStore.from_documents(
        documents=documents,
        embedding=embeddings,
        url=f"http://{QDRANT_HOST}:{QDRANT_PORT}",
        collection_name=COLLECTION_NAME,
    )

    print(f"💾 Successfully uploaded {len(documents)} documents to Qdrant.")

def main():
    print("🚀 Initializing ART Memory...")
    docs = load_documents()
    initialize_vector_db(docs)
    print("✅ Initialization complete.")

if __name__ == "__main__":
    main()
