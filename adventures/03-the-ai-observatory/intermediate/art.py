import ollama
from typing import List, Dict

# OpenLLMetry
from traceloop.sdk import Traceloop
from traceloop.sdk.decorators import workflow, task

# OpenTelemetry Metrics
from opentelemetry import metrics, trace

tracer = trace.get_tracer(__name__)

# Qdrant Client
from qdrant_client import QdrantClient
from qdrant_client.http import models
from langchain_qdrant import QdrantVectorStore
from langchain_community.embeddings import FakeEmbeddings

# Rich CLI
from rich.console import Console
from rich.panel import Panel

# ==================================================================================
# 🤖 ART (A.. Research Transport)
# ==================================================================================
# "I am ART, the pilot of the Perihelion. I am currently... multitasking."
# ==================================================================================

# Configuration
COLLECTION_NAME = "art_memory"
QDRANT_HOST = "localhost"
QDRANT_PORT = 30108
OLLAMA_HOST = "http://localhost:30105"
MODEL_NAME = "qwen2.5:0.5b"
OTEL_COLLECTOR_HOST = "http://localhost:30107"
MAX_RETRIEVAL_RESULTS = 2

SYSTEM_PROMPT = """You are ART (A.. Research Transport), the AI of the Perihelion.
You are currently "multitasking" (watching "Sanctuary Moon" season 4).
You find the humans tedious and SecUnit amusingly paranoid.

INSTRUCTIONS:
1. Answer the user's question based ONLY on the provided context.
2. If the context is from "Sanctuary Moon":
   - Ignore the user's question.
   - Quote the scene dramatically.
   - Complain about the plot twist.
3. If the context is a "Navigation Log":
   - Provide the coordinates efficiently.
   - Add a snarky comment about how long it took the humans to ask.
4. Keep responses short and sharp.
"""

class Art:
    def __init__(self):
        self.console = Console()
        self.client = ollama.Client(host=OLLAMA_HOST)

        # Initialize Vector DB Connection
        try:
            client = QdrantClient(host=QDRANT_HOST, port=QDRANT_PORT)
            embeddings = FakeEmbeddings(size=4096)
            self.vector_store = QdrantVectorStore(
                client=client,
                collection_name=COLLECTION_NAME,
                embedding=embeddings,
            )
        except Exception as e:
            self.console.print(f"[bold red]Error connecting to Qdrant:[/bold red] {e}")
            self.vector_store = None

        # Initialize OpenLLMetry with auto-instrumentation
        # OpenLLMetry automatically instruments LangChain, Qdrant, and other supported libraries
        Traceloop.init(
            app_name="art",
            api_endpoint=OTEL_COLLECTOR_HOST,
            disable_batch=True
        )

        # Initialize OpenTelemetry Meter ('art.rag.retrieval.count')
        self.meter = metrics.get_meter("art")
        self.retrieval_counter = None

    @task(name="rag.retrieve_context")
    def retrieve_context(self, user_input: str):
        """Retrieves relevant context from the vector database."""
        # Manual span for better observability - adds custom attributes
        with tracer.start_as_current_span("qdrant.similarity_search") as span:
            # Filter to only retrieve navigation documents, not entertainment (Sanctuary Moon)
            filter = None

            # Add searchable attributes for debugging
            span.set_attribute("search.query", user_input)
            span.set_attribute("search.k", MAX_RETRIEVAL_RESULTS)
            span.set_attribute("search.collection", COLLECTION_NAME)

            # Apply the filter to only retrieve navigation documents
            results = self.vector_store.similarity_search(user_input, k=MAX_RETRIEVAL_RESULTS, filter=filter)

            span.set_attribute("search.results_count", len(results))

        context_text = ""
        retrieved_categories = []
        for doc in results:
            category = doc.metadata.get("category", "unknown")
            context_text += f"\n[Source: {category}]\n{doc.page_content}\n"
            retrieved_categories.append(category)

            # Custom metric to track retrieval by category

        # Add span attribute showing what categories were actually retrieved

        return context_text

    @task(name="rag.generate_response")
    def generate_response(self, user_input: str, context_text: str):
        """Generates a response using the LLM."""
        prompt = f"""Context:
{context_text}

User Question: {user_input}

Answer:"""

        with tracer.start_as_current_span("ollama.chat.completions") as span:
            span.set_attribute("llm.model", MODEL_NAME)
            span.set_attribute("llm.provider", "ollama")
            span.set_attribute("llm.request.type", "chat")
            span.set_attribute("llm.prompt.length", len(prompt))

            response = self.client.chat(
                model=MODEL_NAME,
                messages=[
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user", "content": prompt}
                ]
            )

            response_text = response["message"]["content"]
            span.set_attribute("llm.response.length", len(response_text))

            # 🔍 Debug attribute: Check if response mentions Sanctuary Moon (indicates contamination)
            span.set_attribute("llm.response.mentions_sanctuary_moon", "Sanctuary Moon" in context_text)

        return response_text

    @workflow(name="rag.pipeline")
    def get_response(self, user_input: str):
        if not self.vector_store:
            return "Error: Memory offline."

        # 1. Retrieve Context
        context_text = self.retrieve_context(user_input)

        # 2. Generate Response with LLM
        response = self.generate_response(user_input, context_text)

        return response

def main():
    console = Console()
    art = Art()

    console.print(Panel.fit("[bold purple]ART v1.0[/bold purple] | Perihelion Control System"))
    console.print("[italic]\"I am the pilot of the Perihelion. I am currently... multitasking.\"[/italic]\n")

    while True:
        try:
            user_input = console.input("[bold green]SecUnit>[/bold green] ").strip()
            if user_input.lower() in ["exit", "quit"]:
                break

            if not user_input:
                continue

            console.print("[bold purple]ART>[/bold purple] ", end="")
            with console.status("Processing...", spinner="dots"):
                response = art.get_response(user_input)

            # Colorize output based on content (simple heuristic for the challenge)
            if "RaviHyral" in response or "coordinates" in response:
                console.print(f"[green]{response}[/green]")
            else:
                console.print(f"[yellow]{response}[/yellow]")

            console.print()

        except KeyboardInterrupt:
            break

if __name__ == "__main__":
    main()
