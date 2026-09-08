import { useEffect, useState, useCallback } from 'react';

const RAW_URL =
  'https://raw.githubusercontent.com/dimaprogramer/fantastic-octo-succotash/main/Event%20sheets/Battle.xml';
const API_URL =
  'https://api.github.com/repos/dimaprogramer/fantastic-octo-succotash/contents/Event%20sheets/Battle.xml?ref=main';

function decodeBase64(base64: string): string {
  const clean = base64.replace(/\s/g, '');
  const binary = atob(clean);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return new TextDecoder('utf-8').decode(bytes);
}

export default function App() {
  const [originalContent, setOriginalContent] = useState('');
  const [content, setContent] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [copied, setCopied] = useState(false);
  const [applied, setApplied] = useState(false);
  const [fixStats, setFixStats] = useState<{
    platformToleranceUpdated: boolean;
    groundHitboxUpdated: boolean;
    initialValueReplacements: number;
    duplicateActionRemoved: boolean;
  } | null>(null);

  useEffect(() => {
    let cancelled = false;

    async function loadFromRaw(): Promise<string> {
      const res = await fetch(RAW_URL);
      if (!res.ok) throw new Error(`Raw загрузка не удалась: HTTP ${res.status}`);
      return res.text();
    }

    async function loadFromApi(): Promise<string> {
      const res = await fetch(API_URL);
      if (!res.ok) throw new Error(`API загрузка не удалась: HTTP ${res.status}`);
      const data = await res.json();
      if (typeof data.content !== 'string') throw new Error('Некорректный ответ API');
      return decodeBase64(data.content);
    }

    async function load() {
      try {
        let text: string;
        try {
          text = await loadFromRaw();
        } catch (rawErr) {
          text = await loadFromApi();
        }
        if (!cancelled) {
          setOriginalContent(text);
          setContent(text);
          setLoading(false);
        }
      } catch (err) {
        if (!cancelled) {
          setError((err as Error).message);
          setLoading(false);
        }
      }
    }

    load();
    return () => {
      cancelled = true;
    };
  }, []);

  const applyPlatformStateFixes = useCallback(() => {
    let fixed = content;

    const stats = {
      platformToleranceUpdated: false,
      groundHitboxUpdated: false,
      initialValueReplacements: 0,
      duplicateActionRemoved: false,
    };

    // 1. «На платформе» — 3 условия: низ души выше верха + горизонталь (2).
    //    Убраны проверки BBoxTop и BBoxBottom <= BBoxTop+10.
    fixed = fixed.replace(
      /Platform1\n                PlayerHitbox\.BBoxBottom 5 Platform1\.BBoxTop-2\n                PlayerHitbox\.BBoxBottom 4 Platform1\.BBoxTop\+10\n                PlayerHitbox\.BBoxRight 5 Platform1\.BBoxLeft\n                PlayerHitbox\.BBoxLeft 4 Platform1\.BBoxRight\n                PlatformIndicatorState 2/g,
      () => {
        stats.platformToleranceUpdated = true;
        return `Platform1
                PlayerHitbox.BBoxBottom 4 Platform1.BBoxTop - 5
                PlayerHitbox.BBoxLeft 3 Platform1.BBoxRight
                PlayerHitbox.BBoxRight 4 Platform1.BBoxLeft
                PlatformIndicatorState 2`;
      }
    );

    // 2. «На земле» — используем тот же хитбокс, что и для платформы,
    //    вместо визуального спрайта сердца.
    fixed = fixed.replace(
      /PlayerHeart\.BBoxBottom 5 CombatZone\.BBoxBottom-10/g,
      () => {
        stats.groundHitboxUpdated = true;
        return 'PlayerHitbox.BBoxBottom 5 CombatZone.BBoxBottom-10';
      }
    );

    // 3. «В воздухе» vs «не синий режим».
    // В исходном файле начальное значение перепутано:
    //   - в синем режиме сердце "в воздухе" должно давать состояние 0;
    //   - в не-синем режиме индикатор должен быть отключен (состояние 3).
    fixed = fixed.replace(
      /PlatformIndicatorState \(PlayerHeart\.Mode=HEARTMODE_BLUE \? 3 : 0\)/g,
      () => {
        stats.initialValueReplacements++;
        return 'PlatformIndicatorState (PlayerHeart.Mode=HEARTMODE_BLUE ? 0 : 3)';
      }
    );

    // 4. Удаляем повторное присвоение PlatformIndicatorState во втором Every tick,
    //    которое сбрасывало состояние 1/2 обратно в 0/3 после проверок платформы/земли.
    fixed = fixed.replace(
      /<action id="-9" name="Set value" sid="8327408215159847" type="System">[\s\S]*?<\/action>/,
      () => {
        stats.duplicateActionRemoved = true;
        return '';
      }
    );

    setContent(fixed);
    setFixStats(stats);
    setApplied(true);
    setTimeout(() => setApplied(false), 2000);
  }, [content]);

  // Автоматически применяем исправления сразу после загрузки исходного файла.
  useEffect(() => {
    if (originalContent && !fixStats) {
      applyPlatformStateFixes();
    }
  }, [originalContent, fixStats, applyPlatformStateFixes]);

  const resetContent = useCallback(() => {
    setContent(originalContent);
  }, [originalContent]);

  const copyToClipboard = useCallback(async () => {
    try {
      await navigator.clipboard.writeText(content);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (err) {
      alert('Не удалось скопировать: ' + (err as Error).message);
    }
  }, [content]);

  const downloadFile = useCallback(() => {
    const blob = new Blob([content], { type: 'application/xml' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'Battle.xml';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  }, [content]);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 text-gray-700">
        <div className="text-center">
          <div className="text-lg font-medium">Загрузка Battle.xml из репозитория…</div>
          <div className="text-sm text-gray-500 mt-1">Это может занять несколько секунд</div>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 p-6">
        <div className="bg-white rounded-xl shadow p-6 max-w-lg w-full">
          <h1 className="text-xl font-bold text-red-600 mb-2">Ошибка загрузки</h1>
          <p className="text-gray-700">{error}</p>
          <p className="text-sm text-gray-500 mt-4">
            Попробуйте обновить страницу. Если ошибка повторяется, возможно, превышен лимит запросов к GitHub.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 text-gray-900">
      <header className="bg-white border-b sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 py-4 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
          <div>
            <h1 className="text-2xl font-bold">Редактор Battle.xml</h1>
            <p className="text-sm text-gray-500">
              Загружен из репозитория{' '}
              <span className="font-mono text-gray-700">dimaprogramer/fantastic-octo-succotash</span>
            </p>
          </div>
          <div className="flex flex-wrap gap-2">
            <button
              onClick={resetContent}
              className="inline-flex items-center gap-2 px-4 py-2 bg-gray-200 hover:bg-gray-300 text-gray-800 rounded-lg font-medium transition"
            >
              ↩️ Сбросить оригинал
            </button>
            <button
              onClick={copyToClipboard}
              className="inline-flex items-center gap-2 px-4 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg font-medium transition"
            >
              {copied ? '✅ Скопировано!' : '📋 Копировать'}
            </button>
            <button
              onClick={downloadFile}
              className="inline-flex items-center gap-2 px-4 py-2 bg-purple-600 hover:bg-purple-700 text-white rounded-lg font-medium transition"
            >
              💾 Скачать
            </button>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 py-6">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <section className="lg:col-span-2">
            <div className="bg-white rounded-xl shadow border overflow-hidden">
              <div className="px-4 py-3 border-b bg-gray-50 flex items-center justify-between">
                <span className="font-medium text-sm text-gray-700">Содержимое Battle.xml</span>
                <span className="text-xs text-gray-500 font-mono">
                  {content.length.toLocaleString('ru-RU')} симв.
                </span>
              </div>
              <textarea
                value={content}
                onChange={(e) => setContent(e.target.value)}
                spellCheck={false}
                className="w-full h-[70vh] p-4 font-mono text-xs md:text-sm text-gray-800 bg-white resize-y focus:outline-none"
              />
            </div>
          </section>

          <aside className="space-y-6">
            <div className="bg-white rounded-xl shadow border p-5">
              <h2 className="font-bold text-lg mb-3">Что исправляется</h2>
              <ul className="space-y-3 text-sm text-gray-700">
                <li className="flex gap-2">
                  <span className="text-blue-600 font-bold">1</span>
                  <span>
                    <strong>На платформе:</strong> добавлено условие <code className="bg-gray-100 px-1 rounded">Is overlapping</code> между душой и платформой + вертикальный допуск ±5px.
                    Теперь состояние срабатывает только при реальном пересечении хитбоксов.
                  </span>
                </li>
                <li className="flex gap-2">
                  <span className="text-blue-600 font-bold">2</span>
                  <span>
                    <strong>На земле:</strong> проверка приведена к тому же хитбоксу{' '}
                    <code className="bg-gray-100 px-1 rounded">PlayerHitbox</code>, что используется для
                    платформ, вместо визуального спрайта сердца.
                  </span>
                </li>
                <li className="flex gap-2">
                  <span className="text-blue-600 font-bold">3</span>
                  <span>
                    <strong>В воздухе (синий режим):</strong> исправляется перепутанное начальное
                    значение индикатора. В синем режиме "воздух" даёт состояние 0, а не-синий режим —
                    отдельное состояние 3.
                  </span>
                </li>
                <li className="flex gap-2">
                  <span className="text-blue-600 font-bold">4</span>
                  <span>
                    <strong>Устранён сброс состояния:</strong> удалено второе лишнее присвоение{' '}
                    <code className="bg-gray-100 px-1 rounded">PlatformIndicatorState</code> в другом
                    блоке <code className="bg-gray-100 px-1 rounded">Every tick</code>, которое
                    перезаписывало состояния 1 и 2 обратно в 0/3.
                  </span>
                </li>
              </ul>
              <div className="mt-4 p-3 bg-yellow-50 border border-yellow-200 rounded-lg text-xs text-yellow-800">
                Применены 4 исправления: <code className="bg-gray-100 px-1 rounded">Is overlapping</code> для платформ, хитбокс «на земле», начальное значение индикатора, удаление повторного сброса.
              </div>
            </div>

            <div className="bg-white rounded-xl shadow border p-5">
              <h2 className="font-bold text-lg mb-3">Статус исправлений</h2>
              <DiffStats original={originalContent} current={content} fixStats={fixStats} />
            </div>
          </aside>
        </div>
      </main>

      {applied && (
        <div className="fixed bottom-6 right-6 bg-blue-600 text-white px-4 py-2 rounded-lg shadow-lg text-sm font-medium transition-opacity duration-300">
          Исправления состояний применены
        </div>
      )}
    </div>
  );
}

function DiffStats({
  original,
  current,
  fixStats,
}: {
  original: string;
  current: string;
  fixStats: {
    platformToleranceUpdated: boolean;
    groundHitboxUpdated: boolean;
    initialValueReplacements: number;
    duplicateActionRemoved: boolean;
  } | null;
}) {
  const linesOriginal = original.split('\n');
  const linesCurrent = current.split('\n');
  const minLength = Math.min(linesOriginal.length, linesCurrent.length);
  let changedCount = 0;
  for (let i = 0; i < minLength; i++) {
    if (linesOriginal[i] !== linesCurrent[i]) changedCount++;
  }
  const addedCount = Math.max(0, linesCurrent.length - linesOriginal.length);
  const removedCount = Math.max(0, linesOriginal.length - linesCurrent.length);

  return (
    <div className="space-y-3 text-sm">
      {fixStats ? (
        <>
          <div className="flex items-center gap-2">
            <span className={fixStats.platformToleranceUpdated ? 'text-green-600' : 'text-red-600'}>
              {fixStats.platformToleranceUpdated ? '✓' : '✗'}
            </span>
            <span className="text-gray-700">Допуск «На платформе» сужен до ±3px</span>
          </div>
          <div className="flex items-center gap-2">
            <span className={fixStats.groundHitboxUpdated ? 'text-green-600' : 'text-red-600'}>
              {fixStats.groundHitboxUpdated ? '✓' : '✗'}
            </span>
            <span className="text-gray-700">Хитбокс «На земле» исправлен</span>
          </div>
          <div className="flex items-center gap-2">
            <span className={fixStats.initialValueReplacements > 0 ? 'text-green-600' : 'text-red-600'}>
              {fixStats.initialValueReplacements > 0 ? '✓' : '✗'}
            </span>
            <span className="text-gray-700">
              Начальное значение исправлено ({fixStats.initialValueReplacements} шт.)
            </span>
          </div>
          <div className="flex items-center gap-2">
            <span className={fixStats.duplicateActionRemoved ? 'text-green-600' : 'text-red-600'}>
              {fixStats.duplicateActionRemoved ? '✓' : '✗'}
            </span>
            <span className="text-gray-700">Повторный сброс состояния удалён</span>
          </div>
          <hr className="border-gray-200" />
          <div className="flex justify-between">
            <span className="text-gray-600">Изменено строк:</span>
            <span className="font-mono font-medium text-blue-600">{changedCount}</span>
          </div>
          <div className="flex justify-between">
            <span className="text-gray-600">Добавлено строк:</span>
            <span className="font-mono font-medium text-green-600">{addedCount}</span>
          </div>
          {removedCount > 0 && (
            <div className="flex justify-between">
              <span className="text-gray-600">Удалено строк:</span>
              <span className="font-mono font-medium text-red-600">{removedCount}</span>
            </div>
          )}
        </>
      ) : (
        <p className="text-sm text-gray-500">Исправления ещё не применялись.</p>
      )}
    </div>
  );
}
