"""Fetch public source archives for the F08.3 extension; no statistical analysis.
Run from any directory. Raw student files remain in the Git-ignored input tree.
"""
from pathlib import Path
import json
import subprocess
import urllib.request

code = Path(__file__).resolve().parent
private = code / 'analysis_for_adversarial_report_output/input/f08'
public = code / 'analysis_for_adversarial_report_output/f08/operational_eligibility_2026-10-19/sources'
public.mkdir(parents=True, exist_ok=True)
archives = {
    '2022': 'https://datosabiertos.mineduc.cl/wp-content/uploads/2022/05/Prueba-de-Transicion-Universitaria-2022-Inscritos-Puntajes.rar',
    '2023': None,
    '2024': 'https://datosabiertos.mineduc.cl/wp-content/uploads/2025/10/PAES-2024-Inscritos-Puntajes.rar',
    '2025': None,
    '2026-Inscritos-Puntajes': 'https://datosabiertos.mineduc.cl/wp-content/uploads/2026/07/PAES-2026-Inscritos-Puntajes.rar',
    '2026-Postulantes': 'https://datosabiertos.mineduc.cl/wp-content/uploads/2026/07/PAES-2026-Postulantes.rar',
    '2026-Matricula': 'https://datosabiertos.mineduc.cl/wp-content/uploads/2026/07/PAES-2026-Matricula.rar',
}
# Read current links from the official index rather than guessing dated paths.
import re
index_url = 'https://datosabiertos.mineduc.cl/pruebas-de-admision-a-la-educacion-superior/'
index = urllib.request.urlopen(index_url, timeout=60).read().decode()
(public / 'admissions_index.html').write_text(index)
links = re.findall(r'href=[\"\x27]([^\"\x27]+)[\"\x27]', index)
for year in ('2022', '2023', '2024', '2025'):
    matches = sorted(set(u for u in links if year in u.split('/')[-1] and 'Inscritos' in u and 'Puntajes' in u))
    if len(matches) != 1:
        raise RuntimeError(f'Inspect changed official index for {year}')
    archives[year] = matches[0]
for name, url in archives.items():
    if name.startswith('2026-'):
        target = private / 'operational_2026'
        archive = target / (name.removeprefix('2026-') + '.rar')
    else:
        target = private / 'operational_raw' / name
        archive = target.parent / (name + '.rar')
    target.mkdir(parents=True, exist_ok=True)
    if not archive.exists():
        urllib.request.urlretrieve(url, archive)
    subprocess.run(['bsdtar', '-xf', str(archive), '-C', str(target)], check=True)
    print(name, archive.stat().st_size, 'bytes')
(public / 'public_archive_urls.json').write_text(json.dumps(archives, indent=2) + '\n')
