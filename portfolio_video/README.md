# Сопровождающее демо-видео

Готовы две версии холодного SMB-демо по сценарию `docs/demo-script.md`:

- `israeli_funds_demo_he.mp4` — мастер на иврите, 83,8 с;
- `israeli_funds_demo_he_github.mp4` — компактная ивритская версия, меньше 5 МБ;
- `israeli_funds_demo_en.mp4` — английский мастер, 78,6 с;
- `israeli_funds_demo_en_github.mp4` — компактная английская версия, меньше 5 МБ;
- `israeli_funds_demo_he.srt` и `israeli_funds_demo_en.srt` — отдельные полные субтитры;
- `thumbnail_he.png` и `thumbnail_en.png` — обложки;
- `contact_sheet_he.png` и `contact_sheet_en.png` — визуальная проверка всех сцен;
- `../docs/demo.gif` — девятисекундный autoplay-фрагмент для README.

Параметры мастеров: 1920×1080, 30 fps, H.264 + AAC 48 kHz, `faststart`, нормализация речи до −16 LUFS / −1,5 dBTP. Короткие подписи уже встроены в изображение; полная речь также доступна в `.srt`.

Визуальный ряд использует реальные скриншоты проекта для Client Questions, Holdings и Gemel. Состояния `0 rows`, read-only и AI Provider отрисованы по фактическому UI и backend-коду. Локальная база `fund_combined_db.db` не входит в репозиторий, поэтому сборка воспроизводима без неё и не имитирует неизвестные результаты.

Озвучка создана мужскими нейроголосами Microsoft (`he-IL-AvriNeural`, `en-US-GuyNeural`). Физический микрофон в автоматической среде не использовался.

## Повторная сборка

Нужны Node.js 18+ и `ffmpeg`/`ffprobe` в `PATH`:

```powershell
cd portfolio_video
npm.cmd install
npm.cmd run build
```

Промежуточные кадры, аудио и части MP4 сохраняются в игнорируемой папке `portfolio_video/assets/`. Итоговые параметры и длительности записываются в `build-report.json`.
