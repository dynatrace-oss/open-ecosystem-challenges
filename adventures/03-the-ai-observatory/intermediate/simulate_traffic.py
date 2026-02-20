import time
import random
from rich.console import Console
from art import Art

# ==================================================================================
# 🚦 Traffic Simulator
# ==================================================================================
# Simulates continuous navigation requests to ART to generate metrics.
# ==================================================================================

def main():
    console = Console()
    console.print("[bold cyan]🚦 Starting Traffic Simulation...[/bold cyan]")
    console.print("Sending navigation requests to ART every 2 seconds.")
    console.print("Press [bold red]Ctrl+C[/bold red] to stop.\n")

    try:
        art = Art()
    except Exception as e:
        console.print(f"[bold red]Error initializing ART:[/bold red] {e}")
        return

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

        # Run query silently (no sleep) to generate metrics faster
        response = art.get_response(query)

        # Print status with Murderbot personality
        if "RaviHyral" in response or "coordinates" in response:
            status = "[green]SUCCESS[/green] (Finally, ART is doing its job.)"
        elif "soap opera" in response or "contract" in response:
            status = "[yellow]DISTRACTED[/yellow] (ART is watching Sanctuary Moon again. Ugh.)"
        else:
            status = "[red]UNKNOWN[/red] (ART is ignoring me. Typical.)"

        console.print(f"[{count}] Query: '{query}' -> {status}")

        time.sleep(2)

if __name__ == "__main__":
    main()
