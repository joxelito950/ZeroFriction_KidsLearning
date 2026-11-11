"""Genera los sonidos de la app (HU-005) por síntesis: campanitas suaves con
notas puras y un ataque y una caída lentos, sin nada estridente. Son de creación
propia, así que no dependen de ninguna licencia de terceros (R6).

    python tool/sounds/generate_sounds.py

Escribe assets/sounds/*.wav (mono, 22 050 Hz, 16 bits). Solo usa la biblioteca
estándar de Python, y el resultado es siempre el mismo.
"""
import math
import struct
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'assets/sounds'
RATE = 22050

# Volumen máximo de la mezcla: moderado (P2). El reproductor no lo sube.
PEAK = 0.45


def note(name: str) -> float:
    """Frecuencia de una nota como 'C5' o 'E6' (temperamento igual, A4 = 440 Hz)."""
    names = {'C': -9, 'D': -7, 'E': -5, 'F': -4, 'G': -2, 'A': 0, 'B': 2}
    semitones = names[name[0]] + (int(name[1:]) - 4) * 12
    return 440.0 * 2 ** (semitones / 12)


def chime(freq: float, length: float, start: float = 0.0) -> list[tuple[float, float, float]]:
    return [(start, length, freq)]


def render(parts: list[tuple[float, float, float]], total: float) -> list[float]:
    """Suma campanitas: la fundamental y un armónico suave, con un ataque de
    8 ms (sin clic) y una caída exponencial."""
    samples = [0.0] * int(total * RATE)
    for start, length, freq in parts:
        first = int(start * RATE)
        for i in range(int(length * RATE)):
            t = i / RATE
            attack = min(1.0, t / 0.008)
            decay = math.exp(-t * 5.0 / length)
            tone = math.sin(2 * math.pi * freq * t) + 0.25 * math.sin(2 * math.pi * freq * 2 * t)
            j = first + i
            if j < len(samples):
                samples[j] += attack * decay * tone
    peak = max(abs(s) for s in samples) or 1.0
    fade = int(0.01 * RATE)
    for i in range(fade):
        samples[-1 - i] *= i / fade
    return [s / peak * PEAK for s in samples]


def write(name: str, samples: list[float]) -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / f'{name}.wav'), 'wb') as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(RATE)
        out.writeframes(b''.join(struct.pack('<h', round(s * 32767)) for s in samples))


def main() -> None:
    # Voltear una carta: un «tic» corto y grave.
    write('flip', render(chime(note('G5'), 0.09), 0.11))
    # Pareja o sombra encajada: dos notas que suben.
    write('match', render(chime(note('C6'), 0.18) + chime(note('E6'), 0.25, 0.08), 0.36))
    # Tablero completado: arpegio de cuatro notas.
    write(
        'complete',
        render(
            chime(note('C5'), 0.3) + chime(note('E5'), 0.3, 0.1) + chime(note('G5'), 0.3, 0.2)
            + chime(note('C6'), 0.5, 0.3),
            0.85,
        ),
    )
    # Insignia o medalla: el arpegio y un brillo arriba, más largo.
    write(
        'badge',
        render(
            chime(note('C5'), 0.35) + chime(note('E5'), 0.35, 0.1) + chime(note('G5'), 0.35, 0.2)
            + chime(note('C6'), 0.5, 0.3) + chime(note('E6'), 0.6, 0.45) + chime(note('G6'), 0.7, 0.6),
            1.35,
        ),
    )


if __name__ == '__main__':
    main()
