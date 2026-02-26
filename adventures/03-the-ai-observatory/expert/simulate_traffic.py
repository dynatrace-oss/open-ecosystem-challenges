import time
import random
from rich.console import Console
from art import Art

# ==================================================================================
# 🚦 Traffic Simulator
# ==================================================================================
# Simulates continuous navigation requests to ART — including faults.
# ~20% of requests simulate a Qdrant timeout (error span).
# ~20% of requests simulate a slow vector search (high-latency span).
# ==================================================================================

FAULT_ERROR_RATE = 0.2   # 20% chance of a simulated Qdrant timeout
FAULT_SLOW_RATE  = 0.2   # 20% chance of a simulated slow query (3s delay)

def main():
    console = Console()
    console.print("[bold cyan]🚦 Starting Traffic Simulation...[/bold cyan]")
    console.print("Sending navigation requests to ART every 2 seconds.")
    console.print(f"Fault injection: {int(FAULT_ERROR_RATE*100)}% errors, {int(FAULT_SLOW_RATE*100)}% slow queries.")
    console.print("Press [bold red]Ctrl+C[/bold red] to stop.\n")

    try:
        art = Art()
    except Exception as e:
        console.print(f"[bold red]Error initializing ART:[/bold red] {e}")
        return

    if not art.vector_store:
        console.print("[bold red]Vector store unavailable. Cannot inject faults or run traffic.[/bold red]")
        return

    # Wrap the vector store's similarity_search to inject faults
    original_search = art.vector_store.similarity_search

    def faulty_search(query, **kwargs):
        roll = random.random()
        if roll < FAULT_ERROR_RATE:
            raise ConnectionError("Simulated Qdrant timeout: vector store unreachable")
        if roll < FAULT_ERROR_RATE + FAULT_SLOW_RATE:
            time.sleep(3)
        return original_search(query, **kwargs)

    art.vector_store.similarity_search = faulty_search

    queries = [
        "Can you calculate the jump to RaviHyral?",
        "What is the status of the jump drive?",
        "Can we get a navigation check?",
        "Is a course correction needed?",
        "Are we there yet?",
    ]

    count = 0
    while True:
        query = random.choice(queries)
        count += 1

        try:
            response = art.get_response(query)

            if "RaviHyral" in response or "coordinates" in response:
                status = "[green]SUCCESS[/green]"
            else:
                status = "[yellow]UNKNOWN[/yellow]"
        except Exception as e:
            status = f"[red]ERROR[/red] ({e})"

        console.print(f"[{count}] '{query}' -> {status}")
        time.sleep(2)

if __name__ == "__main__":
    main()
