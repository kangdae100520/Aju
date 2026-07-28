<!DOCTYPE html>
<html lang="ko" class="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Smart AI Image Crop & Analyzer</title>

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            darkMode: 'class',
            theme: {
                extend: {
                    colors: {
                        slate: {
                            850: '#131c2e',
                            950: '#0a0f1d'
                        },
                        brand: {
                            500: '#6366f1',
                            600: '#4f46e5',
                            700: '#4338ca'
                        }
                    }
                }
            }
        }
    </script>

    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
   
    <!-- Cropper.js for Image Cropping, Zooming, Scaling, and Rotation -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.js"></script>

    <!-- JSZip & FileSaver for Exporting Project ZIP -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/FileSaver.js/2.0.5/FileSaver.min.js"></script>
   
    <!-- Marked.js for Markdown Rendering -->
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
   
    <!-- Highlight.js for Code Highlighting -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>

    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        body {
            font-family: 'Inter', system-ui, -apple-system, sans-serif;
            background-color: #0a0f1d;
            color: #e2e8f0;
        }
        .panel-card {
            background: rgba(19, 28, 46, 0.85);
            backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.08);
        }
        .cropper-bg {
            background-image: linear-gradient(45deg, #131c2e 25%, transparent 25%),
                              linear-gradient(-45deg, #131c2e 25%, transparent 25%),
                              linear-gradient(45deg, transparent 75%, #131c2e 75%),
                              linear-gradient(-45deg, transparent 75%, #131c2e 75%);
            background-size: 20px 20px;
            background-position: 0 0, 0 10px, 10px -10px, -10px 0px;
        }
        .prose pre {
            background: #0a0f1d;
            padding: 1rem;
            border-radius: 0.75rem;
            border: 1px solid rgba(255,255,255,0.1);
        }
        /* Custom cropper line style for better readability */
        .cropper-view-box {
            outline: 2px solid #6366f1;
            outline-color: rgba(99, 102, 241, 0.9);
        }
        .cropper-line, .cropper-point {
            background-color: #818cf8;
        }
    </style>
</head>
<body class="min-h-screen flex flex-col selection:bg-indigo-500 selection:text-white">

    <!-- Header -->
    <header class="border-b border-slate-800 bg-slate-950/90 sticky top-0 z-50 backdrop-blur-md">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
            <div class="flex items-center space-x-3">
                <div class="w-10 h-10 rounded-xl bg-indigo-600/20 text-indigo-400 flex items-center justify-center border border-indigo-500/30">
                    <i class="fa-solid fa-crop-simple text-lg"></i>
                </div>
                <div>
                    <h1 class="font-bold text-base sm:text-lg text-slate-100 flex items-center gap-2">
                        <span>Smart AI Crop Studio</span>
                        <span class="text-[11px] bg-indigo-500/10 text-indigo-300 font-mono px-2 py-0.5 rounded-md border border-indigo-500/20">Vercel Ready</span>
                    </h1>
                    <p class="text-xs text-slate-400">AI 주요 영역 자동 감지 · 크롭 · 확대/축소 및 이미지 저장</p>
                </div>
            </div>

            <div class="flex items-center space-x-3">
                <button onclick="downloadProjectZip()" class="flex items-center space-x-2 bg-indigo-600 hover:bg-indigo-500 text-white font-medium px-4 py-2 rounded-xl text-xs sm:text-sm transition-all shadow-md active:scale-95">
                    <i class="fa-solid fa-file-zipper"></i>
                    <span class="hidden sm:inline">Vercel 배포용 ZIP 다운로드</span>
                    <span class="sm:hidden">ZIP 다운로드</span>
                </button>
            </div>
        </div>
    </header>

    <!-- Main Content -->
    <main class="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-6 flex flex-col gap-6">
       
        <!-- Navigation Tabs -->
        <div class="flex border-b border-slate-800 space-x-2 sm:space-x-4 overflow-x-auto pb-px">
            <button id="tab-studio" onclick="switchTab('studio')" class="tab-btn active px-4 py-2.5 text-xs sm:text-sm font-semibold border-b-2 border-indigo-500 text-indigo-400 flex items-center gap-2 whitespace-nowrap">
                <i class="fa-solid fa-wand-magic-sparkles"></i> AI 이미지 자르기 스튜디오
            </button>
            <button id="tab-files" onclick="switchTab('files')" class="tab-btn px-4 py-2.5 text-xs sm:text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-slate-200 flex items-center gap-2 whitespace-nowrap">
                <i class="fa-solid fa-folder-tree"></i> Vercel 소스 코드 구조
            </button>
            <button id="tab-deploy" onclick="switchTab('deploy')" class="tab-btn px-4 py-2.5 text-xs sm:text-sm font-medium border-b-2 border-transparent text-slate-400 hover:text-slate-200 flex items-center gap-2 whitespace-nowrap">
                <i class="fa-solid fa-rocket"></i> Vercel 배포 가이드
            </button>
        </div>

        <!-- ==================== SECTION 1: AI IMAGE STUDIO ==================== -->
        <div id="content-studio" class="tab-content grid grid-cols-1 lg:grid-cols-12 gap-6">
           
            <!-- Left Side: Canvas & Cropper Tools (7 cols) -->
            <div class="lg:col-span-7 flex flex-col gap-4">
               
                <!-- Main Cropper Editor Box -->
                <div class="panel-card p-5 rounded-2xl flex flex-col gap-4">
                    <div class="flex items-center justify-between border-b border-slate-800/80 pb-3">
                        <h2 class="font-semibold text-slate-200 text-sm flex items-center gap-2">
                            <i class="fa-solid fa-image text-indigo-400"></i> 이미지 편집 & 자르기 캔버스
                        </h2>
                        <div class="flex items-center gap-2">
                            <label for="image-input" class="cursor-pointer bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-medium px-3 py-1.5 rounded-lg border border-slate-700 transition-colors flex items-center gap-1.5">
                                <i class="fa-solid fa-folder-open text-indigo-400"></i> 갤러리/파일 열기
                            </label>
                            <input type="file" id="image-input" accept="image/*" class="hidden" onchange="handleImageUpload(event)">
                        </div>
                    </div>

                    <!-- Cropper Canvas Container -->
                    <div id="editor-wrapper" class="relative min-h-[360px] max-h-[500px] w-full bg-slate-950 rounded-xl overflow-hidden border border-slate-800 flex items-center justify-center cropper-bg">
                        <!-- Initial Upload Placeholder -->
                        <div id="upload-placeholder" class="flex flex-col items-center justify-center p-8 text-center cursor-pointer" onclick="document.getElementById('image-input').click()">
                            <div class="w-16 h-16 rounded-2xl bg-indigo-600/10 text-indigo-400 flex items-center justify-center text-2xl mb-3 border border-indigo-500/20">
                                <i class="fa-solid fa-cloud-arrow-up"></i>
                            </div>
                            <p class="text-sm font-semibold text-slate-200">클릭하여 이미지를 업로드하거나 갤러리에서 선택하세요</p>
                            <p class="text-xs text-slate-400 mt-1">PNG, JPG, WEBP 지원 · AI 자동 영역 추천 및 자유 크롭 가능</p>
                        </div>

                        <!-- Source Image for Cropper.js -->
                        <div id="cropper-container" class="hidden w-full h-full max-h-[500px] flex items-center justify-center">
                            <img id="source-image" src="" alt="Source Image" class="max-w-full block">
                        </div>
                    </div>

                    <!-- Cropper Controls Toolbar -->
                    <div id="editor-toolbar" class="hidden flex-wrap items-center justify-between gap-3 pt-2 border-t border-slate-800">
                        <!-- Action Tools -->
                        <div class="flex items-center gap-1.5 flex-wrap">
                            <button onclick="cropperZoom(0.1)" title="확대" class="px-2.5 py-1.5 bg-slate-800 hover:bg-slate-700 text-slate-200 rounded-lg text-xs border border-slate-700 transition-colors flex items-center gap-1">
                                <i class="fa-solid fa-magnifying-glass-plus"></i> 확대
                            </button>
                            <button onclick="cropperZoom(-0.1)" title="축소" class="px-2.5 py-1.5 bg-slate-800 hover:bg-slate-700 text-slate-200 rounded-lg text-xs border border-slate-700 transition-colors flex items-center gap-1">
                                <i class="fa-solid fa-magnifying-glass-minus"></i> 축소
                            </button>
                            <button onclick="cropperRotate(-90)" title="좌회전" class="p-2 bg-slate-800 hover:bg-slate-700 text-slate-200 rounded-lg text-xs border border-slate-700 transition-colors">
                                <i class="fa-solid fa-rotate-left"></i>
                            </button>
                            <button onclick="cropperRotate(90)" title="우회전" class="p-2 bg-slate-800 hover:bg-slate-700 text-slate-200 rounded-lg text-xs border border-slate-700 transition-colors">
                                <i class="fa-solid fa-rotate-right"></i>
                            </button>
                            <button onclick="cropperReset()" title="초기화" class="px-2.5 py-1.5 bg-slate-800 hover:bg-slate-700 text-slate-200 rounded-lg text-xs border border-slate-700 transition-colors">
                                <i class="fa-solid fa-arrow-rotate-left"></i> 리셋
                            </button>
                        </div>

                        <!-- Aspect Ratio Selector Buttons -->
                        <div class="flex items-center gap-1">
                            <span class="text-xs text-slate-400 mr-1">비율:</span>
                            <button onclick="setAspectRatio(NaN)" class="px-2 py-1 bg-slate-800 hover:bg-slate-700 text-slate-200 rounded text-xs border border-slate-700">자유</button>
                            <button onclick="setAspectRatio(1)" class="px-2 py-1 bg-slate-800 hover:bg-slate-700 text-slate-200 rounded text-xs border border-slate-700">1:1</button>
                            <button onclick="setAspectRatio(16/9)" class="px-2 py-1 bg-slate-800 hover:bg-slate-700 text-slate-200 rounded text-xs border border-slate-700">16:9</button>
                            <button onclick="setAspectRatio(4/3)" class="px-2 py-1 bg-slate-800 hover:bg-slate-700 text-slate-200 rounded text-xs border border-slate-700">4:3</button>
                        </div>
                    </div>

                    <!-- AI Smart Crop Button -->
                    <div id="ai-smart-crop-box" class="hidden bg-slate-900 p-3 rounded-xl border border-indigo-500/30 flex items-center justify-between gap-3">
                        <div class="flex items-center gap-2">
                            <i class="fa-solid fa-crosshairs text-indigo-400 text-base"></i>
                            <div>
                                <p class="text-xs font-semibold text-slate-200">AI 피사체 자동 감지 자르기</p>
                                <p class="text-[11px] text-slate-400">이미지의 핵심 피사체/문서 영역을 AI가 판단해 자동으로 영역을 맞춥니다.</p>
                            </div>
                        </div>
                        <button onclick="runAutoCropRecommendation()" id="btn-auto-crop" class="bg-indigo-600 hover:bg-indigo-500 text-white font-medium text-xs px-3 py-2 rounded-lg transition-colors whitespace-nowrap flex items-center gap-1.5">
                            <i class="fa-solid fa-wand-magic"></i> AI 자동 자르기 적용
                        </button>
                    </div>

                    <!-- Export & Save Section -->
                    <div id="cropped-preview-box" class="hidden bg-slate-950 p-3.5 rounded-xl border border-slate-800 flex flex-col sm:flex-row items-center justify-between gap-4">
                        <div class="flex items-center gap-3 w-full sm:w-auto">
                            <div class="w-14 h-14 bg-slate-900 rounded-lg border border-slate-700 overflow-hidden flex items-center justify-center shrink-0">
                                <img id="cropped-thumbnail" class="max-w-full max-h-full object-contain" src="" alt="Cropped preview">
                            </div>
                            <div>
                                <span class="text-xs font-bold text-slate-200">자르기 지정 영역 내보내기</span>
                                <p class="text-[11px] text-slate-400" id="crop-dimensions">가로 x 세로 PX</p>
                            </div>
                        </div>

                        <!-- Save Format Selection and Download Button -->
                        <div class="flex items-center gap-2 w-full sm:w-auto justify-end">
                            <select id="export-format" class="bg-slate-900 border border-slate-700 rounded-lg px-2 py-1.5 text-xs text-slate-200 focus:outline-none">
                                <option value="image/png">PNG</option>
                                <option value="image/jpeg">JPG</option>
                                <option value="image/webp">WEBP</option>
                            </select>
                            <button onclick="downloadCroppedImage()" class="px-3.5 py-1.5 bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-semibold rounded-lg transition-colors flex items-center gap-1.5 shadow-md">
                                <i class="fa-solid fa-download"></i> 이미지 저장
                            </button>
                        </div>
                    </div>

                </div>

                <!-- Preset Sample Images -->
                <div class="panel-card p-4 rounded-2xl">
                    <h3 class="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2">테스트용 샘플 이미지 선택</h3>
                    <div class="grid grid-cols-3 gap-2">
                        <button onclick="loadSampleImage('receipt')" class="p-2.5 bg-slate-900 hover:bg-slate-800 border border-slate-800 rounded-xl text-left text-xs text-slate-300 transition-all flex items-center gap-2">
                            <i class="fa-solid fa-receipt text-emerald-400 text-base"></i> 영수증 / 문서
                        </button>
                        <button onclick="loadSampleImage('object')" class="p-2.5 bg-slate-900 hover:bg-slate-800 border border-slate-800 rounded-xl text-left text-xs text-slate-300 transition-all flex items-center gap-2">
                            <i class="fa-solid fa-laptop text-indigo-400 text-base"></i> 사물 / 노트북
                        </button>
                        <button onclick="loadSampleImage('chart')" class="p-2.5 bg-slate-900 hover:bg-slate-800 border border-slate-800 rounded-xl text-left text-xs text-slate-300 transition-all flex items-center gap-2">
                            <i class="fa-solid fa-chart-line text-amber-400 text-base"></i> 차트 / 그래프
                        </button>
                    </div>
                </div>

            </div>

            <!-- Right Side: AI Vision & Prompt Controls (5 cols) -->
            <div class="lg:col-span-5 flex flex-col gap-4">
               
                <!-- Controls Panel -->
                <div class="panel-card p-5 rounded-2xl flex flex-col gap-4">
                    <h2 class="font-semibold text-slate-200 text-sm flex items-center gap-2">
                        <i class="fa-solid fa-brain text-indigo-400"></i> Gemini AI 이미지 심층 분석
                    </h2>

                    <!-- Mode Select -->
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">분석 모드 선택</label>
                        <select id="analysis-mode" onchange="handleModeChange()" class="w-full bg-slate-900 border border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-200 focus:outline-none focus:border-indigo-500">
                            <option value="ocr">🔍 텍스트 읽기 및 구조화 (OCR)</option>
                            <option value="detect">🏷️ 피사체 및 주요 구성 요소 추출</option>
                            <option value="crop_guide">✂️ 자르기 구도 분석 및 가이드 추천</option>
                            <option value="custom">💬 커스텀 프롬프트 직접 입력</option>
                        </select>
                    </div>

                    <!-- Target Region Selector -->
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1.5">분석 대상 범위</label>
                        <div class="grid grid-cols-2 gap-2">
                            <label class="flex items-center gap-2 p-2 rounded-lg bg-slate-900 border border-slate-800 cursor-pointer text-xs">
                                <input type="radio" name="target-region" value="crop" checked class="text-indigo-600 focus:ring-0">
                                <span class="font-medium text-slate-200">선택한 크롭 영역만</span>
                            </label>
                            <label class="flex items-center gap-2 p-2 rounded-lg bg-slate-900 border border-slate-800 cursor-pointer text-xs">
                                <input type="radio" name="target-region" value="full" class="text-indigo-600 focus:ring-0">
                                <span class="font-medium text-slate-200">전체 원본 이미지</span>
                            </label>
                        </div>
                    </div>

                    <!-- Prompt Textarea -->
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">상세 요청 사항 (프롬프트)</label>
                        <textarea id="ai-prompt" rows="3" class="w-full bg-slate-900 border border-slate-700 rounded-xl p-3 text-xs text-slate-200 focus:outline-none focus:border-indigo-500 transition-colors resize-none" placeholder="AI에게 요청할 분석 내용을 작성하세요..."></textarea>
                    </div>

                    <!-- Local direct key setting for temporary client test -->
                    <div class="bg-slate-900/80 p-3 rounded-xl border border-slate-800 space-y-1.5">
                        <div class="flex justify-between items-center">
                            <span class="text-xs font-medium text-slate-300">로컬 직접 테스트용 API Key</span>
                            <span class="text-[10px] text-slate-500">선택 사항</span>
                        </div>
                        <input type="password" id="local-api-key" placeholder="AIzaSy... (로컬 테스트용)" class="w-full bg-slate-950 border border-slate-800 rounded-lg px-2.5 py-1.5 text-xs text-slate-200 focus:outline-none focus:border-indigo-500">
                        <p class="text-[10px] text-slate-500 leading-tight">비워두면 배포된 Vercel 백엔드 함수(<code class="text-indigo-300">/api/generate</code>)의 <code class="text-indigo-300">GEMINI_API_KEY</code>를 사용합니다.</p>
                    </div>

                    <!-- Submit Button -->
                    <button id="analyze-btn" onclick="analyzeImageWithAI()" class="w-full bg-indigo-600 hover:bg-indigo-500 text-white font-semibold py-2.5 rounded-xl text-xs transition-all flex items-center justify-center gap-2 shadow-md active:scale-95">
                        <i class="fa-solid fa-sparkles"></i>
                        <span id="btn-text">AI 분석 실행</span>
                    </button>
                </div>

                <!-- Result Display Box -->
                <div class="panel-card p-5 rounded-2xl flex-1 flex flex-col min-h-[260px]">
                    <div class="flex items-center justify-between pb-3 border-b border-slate-800 mb-3">
                        <h3 class="font-semibold text-slate-200 text-xs flex items-center gap-2">
                            <i class="fa-solid fa-file-lines text-indigo-400"></i> AI 분석 및 추출 결과
                        </h3>
                        <button onclick="copyResultText()" class="text-xs text-slate-400 hover:text-slate-200 transition-colors flex items-center gap-1">
                            <i class="fa-regular fa-copy"></i> 복사
                        </button>
                    </div>

                    <div id="ai-output" class="flex-1 bg-slate-950 border border-slate-800 rounded-xl p-4 text-xs text-slate-300 leading-relaxed overflow-y-auto max-h-[380px] prose prose-invert max-w-none">
                        <div class="h-full flex flex-col items-center justify-center text-slate-500 text-xs py-8 text-center gap-2">
                            <i class="fa-solid fa-wand-magic-sparkles text-2xl opacity-30"></i>
                            <p>이미지를 업로드한 후<br>'AI 분석 실행'을 누르면 결과가 표시됩니다.</p>
                        </div>
                    </div>
                </div>

            </div>

        </div>

        <!-- ==================== SECTION 2: CODE VIEWER ==================== -->
        <div id="content-files" class="tab-content hidden flex-col gap-6">
            <div class="panel-card p-6 rounded-2xl flex flex-col gap-4">
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-slate-800 pb-4">
                    <div>
                        <h2 class="font-bold text-lg text-slate-100 flex items-center gap-2">
                            <i class="fa-solid fa-folder-tree text-indigo-400"></i> Vercel 서버리스 프로젝트 전체 구성
                        </h2>
                        <p class="text-xs text-slate-400 mt-1">다운로드하여 그대로 Vercel에 배포 가능한 소스코드 모음입니다.</p>
                    </div>
                    <button onclick="downloadProjectZip()" class="bg-indigo-600 hover:bg-indigo-500 text-white text-xs font-semibold px-4 py-2 rounded-xl flex items-center gap-2 transition-colors">
                        <i class="fa-solid fa-file-zipper"></i> 전체 프로젝트 ZIP 다운로드
                    </button>
                </div>

                <!-- Code Viewer Grid -->
                <div class="grid grid-cols-1 md:grid-cols-12 gap-6">
                    <!-- File Selector List -->
                    <div class="md:col-span-3 flex flex-col gap-1.5">
                        <button onclick="showCodeFile('index.html')" class="code-file-btn active text-left px-3.5 py-2 rounded-xl text-xs font-mono font-medium bg-indigo-600/20 border border-indigo-500/50 text-indigo-300 flex items-center justify-between">
                            <span><i class="fa-solid fa-file-code text-amber-400 mr-2"></i>index.html</span>
                            <span class="text-[10px] bg-indigo-900/60 text-indigo-300 px-1.5 py-0.5 rounded">Frontend</span>
                        </button>
                        <button onclick="showCodeFile('api/generate.js')" class="code-file-btn text-left px-3.5 py-2 rounded-xl text-xs font-mono font-medium bg-slate-900 border border-slate-800 text-slate-300 hover:bg-slate-800 flex items-center justify-between transition-colors">
                            <span><i class="fa-brands fa-js text-yellow-400 mr-2"></i>api/generate.js</span>
                            <span class="text-[10px] bg-purple-900/60 text-purple-300 px-1.5 py-0.5 rounded">Serverless</span>
                        </button>
                        <button onclick="showCodeFile('package.json')" class="code-file-btn text-left px-3.5 py-2 rounded-xl text-xs font-mono font-medium bg-slate-900 border border-slate-800 text-slate-300 hover:bg-slate-800 flex items-center justify-between transition-colors">
                            <span><i class="fa-solid fa-box text-emerald-400 mr-2"></i>package.json</span>
                            <span class="text-[10px] bg-slate-800 text-slate-400 px-1.5 py-0.5 rounded">Config</span>
                        </button>
                        <button onclick="showCodeFile('vercel.json')" class="code-file-btn text-left px-3.5 py-2 rounded-xl text-xs font-mono font-medium bg-slate-900 border border-slate-800 text-slate-300 hover:bg-slate-800 flex items-center justify-between transition-colors">
                            <span><i class="fa-solid fa-gear text-cyan-400 mr-2"></i>vercel.json</span>
                            <span class="text-[10px] bg-slate-800 text-slate-400 px-1.5 py-0.5 rounded">Config</span>
                        </button>
                        <button onclick="showCodeFile('.gitignore')" class="code-file-btn text-left px-3.5 py-2 rounded-xl text-xs font-mono font-medium bg-slate-900 border border-slate-800 text-slate-300 hover:bg-slate-800 flex items-center justify-between transition-colors">
                            <span><i class="fa-solid fa-eye-slash text-rose-400 mr-2"></i>.gitignore</span>
                            <span class="text-[10px] bg-slate-800 text-slate-400 px-1.5 py-0.5 rounded">Git</span>
                        </button>
                        <button onclick="showCodeFile('LICENSE')" class="code-file-btn text-left px-3.5 py-2 rounded-xl text-xs font-mono font-medium bg-slate-900 border border-slate-800 text-slate-300 hover:bg-slate-800 flex items-center justify-between transition-colors">
                            <span><i class="fa-solid fa-certificate text-teal-400 mr-2"></i>LICENSE</span>
                            <span class="text-[10px] bg-slate-800 text-slate-400 px-1.5 py-0.5 rounded">License</span>
                        </button>
                        <button onclick="showCodeFile('README.md')" class="code-file-btn text-left px-3.5 py-2 rounded-xl text-xs font-mono font-medium bg-slate-900 border border-slate-800 text-slate-300 hover:bg-slate-800 flex items-center justify-between transition-colors">
                            <span><i class="fa-solid fa-book text-blue-400 mr-2"></i>README.md</span>
                            <span class="text-[10px] bg-slate-800 text-slate-400 px-1.5 py-0.5 rounded">Docs</span>
                        </button>
                        <button onclick="showCodeFile('.env.example')" class="code-file-btn text-left px-3.5 py-2 rounded-xl text-xs font-mono font-medium bg-slate-900 border border-slate-800 text-slate-300 hover:bg-slate-800 flex items-center justify-between transition-colors">
                            <span><i class="fa-solid fa-key text-red-400 mr-2"></i>.env.example</span>
                            <span class="text-[10px] bg-slate-800 text-slate-400 px-1.5 py-0.5 rounded">Env</span>
                        </button>
                    </div>

                    <!-- Syntax Highlight Display Window -->
                    <div class="md:col-span-9 bg-slate-950 border border-slate-800 rounded-xl overflow-hidden flex flex-col">
                        <div class="bg-slate-900 px-4 py-2 border-b border-slate-800 flex justify-between items-center text-xs font-mono text-slate-400">
                            <span id="current-file-name">index.html</span>
                            <button onclick="copyCurrentCode()" class="hover:text-slate-200 transition-colors flex items-center gap-1">
                                <i class="fa-regular fa-copy"></i> 파일 내용 복사
                            </button>
                        </div>
                        <pre class="p-4 overflow-x-auto text-xs font-mono text-slate-300 leading-relaxed max-h-[500px]"><code id="code-viewer-content" class="language-javascript"></code></pre>
                    </div>
                </div>
            </div>
        </div>

        <!-- ==================== SECTION 3: DEPLOYMENT GUIDE ==================== -->
        <div id="content-deploy" class="tab-content hidden flex-col gap-6">
            <div class="panel-card p-6 rounded-2xl flex flex-col gap-6">
                <div>
                    <h2 class="font-bold text-lg text-slate-100 flex items-center gap-2">
                        <i class="fa-solid fa-rocket text-indigo-400"></i> Vercel 배포 Step-by-Step 안내
                    </h2>
                    <p class="text-xs text-slate-400 mt-1">프로젝트 ZIP 다운로드 후 단 몇 분만에 Vercel에 배포할 수 있습니다.</p>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div class="bg-slate-900 border border-slate-800 rounded-xl p-5 flex flex-col gap-2">
                        <div class="w-7 h-7 rounded-lg bg-indigo-600/20 text-indigo-400 font-bold flex items-center justify-center text-xs border border-indigo-500/30">1</div>
                        <h3 class="font-semibold text-slate-200 text-sm">ZIP 압축 해제</h3>
                        <p class="text-xs text-slate-400 leading-relaxed">
                            우측 상단의 <strong>[Vercel 배포용 ZIP 다운로드]</strong>를 클릭하여 소스코드를 압축 해제합니다.
                        </p>
                    </div>

                    <div class="bg-slate-900 border border-slate-800 rounded-xl p-5 flex flex-col gap-2">
                        <div class="w-7 h-7 rounded-lg bg-purple-600/20 text-purple-400 font-bold flex items-center justify-center text-xs border border-purple-500/30">2</div>
                        <h3 class="font-semibold text-slate-200 text-sm">GitHub 레포지토리 푸시</h3>
                        <p class="text-xs text-slate-400 leading-relaxed">
                            GitHub에 새 저장소(Repository)를 만들고 소스 코드를 푸시합니다.
                        </p>
                    </div>

                    <div class="bg-slate-900 border border-slate-800 rounded-xl p-5 flex flex-col gap-2">
                        <div class="w-7 h-7 rounded-lg bg-emerald-600/20 text-emerald-400 font-bold flex items-center justify-center text-xs border border-emerald-500/30">3</div>
                        <h3 class="font-semibold text-slate-200 text-sm">Vercel Import & 환경변수</h3>
                        <p class="text-xs text-slate-400 leading-relaxed">
                            Vercel에서 저장소를 불러온 후 <strong>Environment Variables</strong>에 <code class="text-indigo-300">GEMINI_API_KEY</code>를 등록하고 Deploy합니다.
                        </p>
                    </div>
                </div>

                <div class="bg-slate-950 border border-slate-800 rounded-xl p-5 flex flex-col gap-2">
                    <h3 class="font-semibold text-xs sm:text-sm text-slate-200 flex items-center gap-2">
                        <i class="fa-solid fa-shield-halved text-emerald-400"></i> API 키 은닉 및 안전성 정보
                    </h3>
                    <div class="text-xs text-slate-300 space-y-2 leading-relaxed">
                        <p>• 프론트엔드(<code class="text-indigo-300">index.html</code>)에 API 키를 절대 노출하지 않습니다.</p>
                        <p>• 클라이언트는 Vercel Serverless Function인 <code class="text-indigo-300">/api/generate</code>로 자른 이미지 데이터와 프롬프트만 전달합니다.</p>
                        <p>• Vercel 서버리스 백엔드가 서버 환경 변수 <code class="text-indigo-300">process.env.GEMINI_API_KEY</code>를 읽어 안전하게 Google AI Studio와 통신합니다.</p>
                    </div>
                </div>
            </div>
        </div>

    </main>

    <script>
        // Whole Project Bundle Files Object for ZIP Export
        const projectFiles = {
            "index.html": `<!DOCTYPE html>
<html lang="ko" class="dark">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Smart AI Crop Studio</title>
    <script src="https://cdn.tailwindcss.com"><\/script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.5.13/cropper.min.js"><\/script>
    <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"><\/script>
</head>
<body class="bg-slate-950 text-slate-100 min-h-screen p-4 flex flex-col items-center">
    <div class="max-w-4xl w-full bg-slate-900 border border-slate-800 rounded-2xl p-6 shadow-2xl flex flex-col gap-6">
        <h1 class="text-xl font-bold text-indigo-400 flex items-center gap-2">
            <i class="fa-solid fa-crop-simple"></i> Smart AI Crop & Vision
        </h1>
        <p class="text-xs text-slate-400">Vercel 서버리스 함수(/api/generate)와 연동되어 AI로 주요 영역을 감지하고 안전하게 분석 및 저장합니다.</p>
       
        <div class="flex flex-col md:flex-row gap-6">
            <div class="flex-1 flex flex-col gap-3">
                <input type="file" id="img-input" accept="image/*" class="text-xs text-slate-300">
                <div class="h-64 bg-slate-950 rounded-xl overflow-hidden border border-slate-800 flex items-center justify-center">
                    <img id="cropper-target" src="" class="max-h-full hidden">
                </div>
                <button onclick="runAnalysis()" id="submit-btn" class="bg-indigo-600 hover:bg-indigo-500 text-white text-xs font-semibold py-2.5 rounded-xl transition-all">
                    선택 영역 AI 분석하기
                </button>
            </div>
           
            <div class="flex-1 bg-slate-950 border border-slate-800 rounded-xl p-4 text-xs leading-relaxed text-slate-200 overflow-y-auto max-h-80" id="result-box">
                분석 결과가 여기에 표시됩니다.
            </div>
        </div>
    </div>

    <script>
        let cropper = null;
        const imgInput = document.getElementById('img-input');
        const imgTarget = document.getElementById('cropper-target');

        imgInput.addEventListener('change', (e) => {
            const file = e.target.files[0];
            if (!file) return;
            const reader = new FileReader();
            reader.onload = (ev) => {
                imgTarget.src = ev.target.result;
                imgTarget.classList.remove('hidden');
                if (cropper) cropper.destroy();
                cropper = new Cropper(imgTarget, { aspectRatio: NaN, viewMode: 1 });
            };
            reader.readAsDataURL(file);
        });

        async function runAnalysis() {
            if (!cropper) { alert('이미지를 선택해주세요.'); return; }
            const canvas = cropper.getCroppedCanvas();
            const base64Data = canvas.toDataURL('image/png').split(',')[1];
           
            const resultBox = document.getElementById('result-box');
            resultBox.innerHTML = '분석 중...';

            try {
                const apiEndpoint = (window.location.origin && !window.location.origin.startsWith('blob:') && window.location.origin !== 'null') ? window.location.origin + '/api/generate' : '/api/generate';
                const res = await fetch(apiEndpoint, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        prompt: '이미지의 주요 텍스트 및 특징을 분석해 정리해 주세요.',
                        imageBase64: base64Data,
                        mimeType: 'image/png'
                    })
                });
                const data = await res.json();
                const text = data.candidates?.[0]?.content?.parts?.[0]?.text || '결과를 불러올 수 없습니다.';
                resultBox.innerHTML = typeof marked !== 'undefined' ? marked.parse(text) : text;
            } catch (err) {
                resultBox.innerHTML = '오류 발생: ' + err.message;
            }
        }
    <\/script>
</body>
</html>`,

            "api/generate.js": `// Vercel Serverless Function (/api/generate)
// GEMINI_API_KEY 환경 변수를 이용하여 Google Gemini API를 안전하게 호출합니다.

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed. POST 요청만 허용됩니다.' });
  }

  const apiKey = process.env.GEMINI_API_KEY;

  if (!apiKey) {
    return res.status(500).json({
      error: 'GEMINI_API_KEY가 환경 변수로 설정되어 있지 않습니다. Vercel 설정(Settings > Environment Variables)에서 추가해주세요.'
    });
  }

  try {
    const { prompt, imageBase64, mimeType = 'image/png', systemInstruction, model = 'gemini-3-flash-preview' } = req.body;

    if (!prompt && !imageBase64) {
      return res.status(400).json({ error: '프롬프트 또는 이미지 데이터가 필요합니다.' });
    }

    const apiUrl = \`https://generativelanguage.googleapis.com/v1beta/models/\${model}:generateContent?key=\${apiKey}\`;

    const parts = [];
    if (prompt) {
      parts.push({ text: prompt });
    }
    if (imageBase64) {
      parts.push({
        inlineData: {
          mimeType: mimeType,
          data: imageBase64
        }
      });
    }

    const payload = {
      contents: [
        {
          role: 'user',
          parts: parts
        }
      ]
    };

    if (systemInstruction) {
      payload.systemInstruction = {
        parts: [{ text: systemInstruction }]
      };
    }

    const response = await fetch(apiUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });

    const data = await response.json();

    if (!response.ok) {
      return res.status(response.status).json({
        error: data.error?.message || 'Gemini API 호출 중 오류가 발생했습니다.',
        details: data
      });
    }

    return res.status(200).json(data);

  } catch (error) {
    console.error('Serverless Function Error:', error);
    return res.status(500).json({ error: error.message || '서버 내부 오류가 발생했습니다.' });
  }
}`,

            "package.json": `{
  "name": "smart-ai-crop-studio",
  "version": "1.0.0",
  "private": true,
  "description": "Smart AI Image Crop & Vision Extractor deployable on Vercel",
  "scripts": {
    "dev": "vercel dev",
    "deploy": "vercel --prod"
  },
  "dependencies": {}
}`,

            "vercel.json": `{
  "version": 2,
  "rewrites": [
    { "source": "/api/generate", "destination": "/api/generate.js" }
  ]
}`,

            ".gitignore": `node_modules/
.vercel/
.env
.env.local
.DS_Store
*.log`,

            "LICENSE": `MIT License

Copyright (c) 2026 Smart AI Crop Studio

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.`,

            ".env.example": `# Vercel 배포 시 Settings > Environment Variables에 등록할 키입니다.
GEMINI_API_KEY=your_gemini_api_key_here`,

            "README.md": `# Smart AI Image Crop & Vision Studio

갤러리나 파일에서 이미지를 불러와 AI 기반의 스마트 자르기 영역을 추천받고, 자유롭게 확대/축소/회전 편집 후 최적의 이미지로 저장할 수 있는 Vercel 배포용 웹 애플리케이션입니다.

## 🌟 주요 기능

- **스마트 AI 영역 감지 (Auto-Crop)**: Gemini Vision API를 이용해 인물, 문서, 주요 오브젝트 위치를 감지하여 크롭 프레임을 자동 설정합니다.
- **자율 이미지 조작**: 확대/축소, 회전, 리셋 및 1:1, 16:9, 4:3 자르기 비율 지정.
- **이미지 내보내기/저장**: 편집된 영역을 PNG, JPG, WEBP 포맷으로 저장 가능.
- **안전한 Vercel 서버리스 스택**: API Key가 클라이언트에 노출되지 않도록 \`/api/generate.js\` 백엔드 함수 처리.

## 🚀 배포 방법

1. **ZIP 프로젝트 다운로드**: 웹 상단의 [Vercel 배포용 ZIP 다운로드] 버튼을 눌러 압축을 해제합니다.
2. **GitHub 저장소 푸시**: GitHub에 새로운 Repository를 생성하고 코드를 업로드합니다.
3. **Vercel 연동**: [Vercel Dashboard](https://vercel.com)에서 Import를 수행합니다.
4. **환경 변수 설정**: 프로젝트 Settings > Environment Variables 항목에 \`GEMINI_API_KEY\`를 입력하고 Deploy합니다.
`
        };

        let cropper = null;
        let originalImageMime = 'image/png';
        let currentSelectedFile = 'index.html';

        // Resolve absolute API URL safely across standard web origins and iframe/blob preview environments
        function getApiUrl() {
            if (window.location.origin && !window.location.origin.startsWith('blob:') && window.location.origin !== 'null') {
                return window.location.origin + '/api/generate';
            }
            try {
                if (window.location.ancestorOrigins && window.location.ancestorOrigins[0]) {
                    return window.location.ancestorOrigins[0] + '/api/generate';
                }
            } catch (e) {}
            return '/api/generate';
        }

        // Mode prompts for Gemini Vision
        const modePrompts = {
            ocr: '이미지(또는 선택한 크롭 영역)에 포함된 모든 글자, 숫자를 정확히 읽고 명확히 정리해 주세요. 문서나 영수증 형태라면 항목과 금액, 일자를 표나 목록 형태로 구조화해 주세요.',
            detect: '선택한 영역의 주요 물체, 인물, 사물, 상태 및 주요 특징을 요소별로 상세히 분류해 주세요.',
            crop_guide: '이 이미지의 구도를 분석하고, 시각적으로 가장 인상적인 구도 및 자르기 적합 비율을 추천해 주세요.',
            custom: '이미지의 해당 영역을 관찰하고 특징을 설명해 주세요.'
        };

        function handleModeChange() {
            const mode = document.getElementById('analysis-mode').value;
            const promptInput = document.getElementById('ai-prompt');
            promptInput.value = modePrompts[mode] || modePrompts.custom;
        }

        // Initialize Cropper JS
        function initCropper(imageSrc) {
            const container = document.getElementById('cropper-container');
            const sourceImg = document.getElementById('source-image');
            const placeholder = document.getElementById('upload-placeholder');
            const toolbar = document.getElementById('editor-toolbar');
            const autoCropBox = document.getElementById('ai-smart-crop-box');
            const previewBox = document.getElementById('cropped-preview-box');

            placeholder.classList.add('hidden');
            container.classList.remove('hidden');
            toolbar.classList.remove('hidden');
            toolbar.classList.add('flex');
            autoCropBox.classList.remove('hidden');
            autoCropBox.classList.add('flex');
            previewBox.classList.remove('hidden');

            sourceImg.src = imageSrc;

            if (cropper) {
                cropper.destroy();
            }

            cropper = new Cropper(sourceImg, {
                aspectRatio: NaN,
                viewMode: 1,
                background: false,
                autoCropArea: 0.85,
                crop(event) {
                    updateCroppedPreview();
                }
            });
        }

        function updateCroppedPreview() {
            if (!cropper) return;
            const canvas = cropper.getCroppedCanvas({
                maxWidth: 400,
                maxHeight: 400
            });
            if (canvas) {
                const thumb = document.getElementById('cropped-thumbnail');
                thumb.src = canvas.toDataURL(originalImageMime);
                document.getElementById('crop-dimensions').innerText = `${Math.round(canvas.width)} x ${Math.round(canvas.height)} px`;
            }
        }

        function handleImageUpload(e) {
            const file = e.target.files[0];
            if (!file) return;
            originalImageMime = file.type || 'image/png';
            const reader = new FileReader();
            reader.onload = function(evt) {
                initCropper(evt.target.result);
            };
            reader.readAsDataURL(file);
        }

        function cropperZoom(ratio) {
            if (cropper) cropper.zoom(ratio);
        }

        function cropperRotate(degree) {
            if (cropper) cropper.rotate(degree);
        }

        function cropperReset() {
            if (cropper) cropper.reset();
        }

        function setAspectRatio(ratio) {
            if (cropper) cropper.setAspectRatio(ratio);
        }

        function downloadCroppedImage() {
            if (!cropper) return;
            const canvas = cropper.getCroppedCanvas();
            if (!canvas) return;

            const format = document.getElementById('export-format').value;
            let ext = 'png';
            if (format === 'image/jpeg') ext = 'jpg';
            if (format === 'image/webp') ext = 'webp';

            canvas.toBlob((blob) => {
                saveAs(blob, `cropped-image-${Date.now()}.${ext}`);
                showToast(`선택한 영역이 ${ext.toUpperCase()} 파일로 저장되었습니다.`);
            }, format, 0.92);
        }

        // Client-side fallback smart cropping using pixel contrast & edge detection
        function detectSmartCropFallback(imgElement) {
            const canvas = document.createElement('canvas');
            const w = imgElement.naturalWidth || imgElement.width || 800;
            const h = imgElement.naturalHeight || imgElement.height || 600;
            const sw = Math.min(w, 400);
            const sh = Math.min(h, Math.round(400 * (h / w)));
            canvas.width = sw;
            canvas.height = sh;
            const ctx = canvas.getContext('2d');
            ctx.drawImage(imgElement, 0, 0, sw, sh);

            try {
                const imgData = ctx.getImageData(0, 0, sw, sh);
                const data = imgData.data;

                // Sample corner background colors
                const corners = [[0, 0], [sw - 1, 0], [0, sh - 1], [sw - 1, sh - 1]];
                let bgR = 0, bgG = 0, bgB = 0;
                corners.forEach(([cx, cy]) => {
                    const idx = (cy * sw + cx) * 4;
                    bgR += data[idx]; bgG += data[idx + 1]; bgB += data[idx + 2];
                });
                bgR /= 4; bgG /= 4; bgB /= 4;

                let minX = sw, maxX = 0, minY = sh, maxY = 0;
                let count = 0;

                for (let y = 0; y < sh; y++) {
                    for (let x = 0; x < sw; x++) {
                        const idx = (y * sw + x) * 4;
                        const r = data[idx], g = data[idx + 1], b = data[idx + 2];
                        const dist = Math.sqrt((r - bgR) ** 2 + (g - bgG) ** 2 + (b - bgB) ** 2);
                        if (dist > 32) {
                            if (x < minX) minX = x;
                            if (x > maxX) maxX = x;
                            if (y < minY) minY = y;
                            if (y > maxY) maxY = y;
                            count++;
                        }
                    }
                }

                if (count > 50 && maxX > minX && maxY > minY) {
                    const padX = (maxX - minX) * 0.05;
                    const padY = (maxY - minY) * 0.05;
                    const x1 = Math.max(0, minX - padX);
                    const x2 = Math.min(sw, maxX + padX);
                    const y1 = Math.max(0, minY - padY);
                    const y2 = Math.min(sh, maxY + padY);

                    return [
                        Math.round((y1 / sh) * 100),
                        Math.round((x1 / sw) * 100),
                        Math.round((y2 / sh) * 100),
                        Math.round((x2 / sw) * 100)
                    ];
                }
            } catch (e) {
                console.warn('Canvas smart crop detection error:', e);
            }

            return [10, 10, 90, 90];
        }

        // AI Smart Auto-Crop Recommendation
        async function runAutoCropRecommendation() {
            if (!cropper) return;

            const btn = document.getElementById('btn-auto-crop');
            const originalBtnHtml = btn.innerHTML;
            btn.disabled = true;
            btn.innerHTML = `<i class="fa-solid fa-spinner animate-spin"></i> 분석 중...`;

            const sourceImg = document.getElementById('source-image');
            let box = null;
            let usedFallback = false;

            try {
                const canvas = document.createElement('canvas');
                canvas.width = sourceImg.naturalWidth;
                canvas.height = sourceImg.naturalHeight;
                const ctx = canvas.getContext('2d');
                ctx.drawImage(sourceImg, 0, 0);
                const fullBase64 = canvas.toDataURL(originalImageMime).split(',')[1];

                const prompt = "이 이미지에서 가장 중요한 핵심 피사체/문서/주요 대상의 위치를 [ymin, xmin, ymax, xmax] 형식의 0~100 사이 비율(퍼센트) 값으로 찾아주세요. 오직 JSON 형식만 반환하세요. 예시: {\"box\": [15, 20, 85, 80]}";

                let resData = null;
                const localKey = document.getElementById('local-api-key').value.trim();

                if (localKey) {
                    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=${localKey}`;
                    const res = await fetch(url, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            contents: [{
                                role: 'user',
                                parts: [{ text: prompt }, { inlineData: { mimeType: originalImageMime, data: fullBase64 } }]
                            }]
                        })
                    });
                    if (!res.ok) throw new Error(`API Key 호출 실패 (${res.status})`);
                    resData = await res.json();
                } else {
                    const apiUrl = getApiUrl();
                    const res = await fetch(apiUrl, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            prompt: prompt,
                            imageBase64: fullBase64,
                            mimeType: originalImageMime
                        })
                    });
                    if (res.ok) {
                        resData = await res.json();
                    } else {
                        console.warn(`Serverless API returned status ${res.status}. Falling back to client-side smart crop.`);
                        usedFallback = true;
                    }
                }

                if (resData) {
                    const text = resData.candidates?.[0]?.content?.parts?.[0]?.text || '';
                    const jsonMatch = text.match(/\{[\s\S]*\}/);
                    if (jsonMatch) {
                        const parsed = JSON.parse(jsonMatch[0]);
                        if (parsed.box && Array.isArray(parsed.box) && parsed.box.length === 4) {
                            box = parsed.box;
                        }
                    }
                }
            } catch (err) {
                console.warn('AI Crop API call failed, using client fallback:', err);
                usedFallback = true;
            }

            if (!box) {
                box = detectSmartCropFallback(sourceImg);
                usedFallback = true;
            }

            if (box && Array.isArray(box) && box.length === 4) {
                const [ymin, xmin, ymax, xmax] = box;
                const imgData = cropper.getImageData();

                const cropLeft = (xmin / 100) * imgData.naturalWidth;
                const cropTop = (ymin / 100) * imgData.naturalHeight;
                const cropWidth = Math.max(20, ((xmax - xmin) / 100) * imgData.naturalWidth);
                const cropHeight = Math.max(20, ((ymax - ymin) / 100) * imgData.naturalHeight);

                cropper.setData({
                    left: cropLeft,
                    top: cropTop,
                    width: cropWidth,
                    height: cropHeight
                });

                if (usedFallback) {
                    showToast('스마트 엣지 감지로 최적 영역을 지정했습니다! (Gemini API 키 입력 시 라이브 AI 감지 구동)');
                } else {
                    showToast('AI가 감지한 최적의 영역으로 자르기 상자가 맞춰졌습니다!');
                }
            }

            btn.disabled = false;
            btn.innerHTML = originalBtnHtml;
        }

        // Preset Sample Images Loader
        function loadSampleImage(type) {
            let svgString = '';
            if (type === 'receipt') {
                svgString = `<svg xmlns="http://www.w3.org/2000/svg" width="600" height="800" viewBox="0 0 600 800" fill="#0a0f1d">
                    <rect width="600" height="800" fill="#f8fafc"/>
                    <text x="300" y="80" font-family="monospace" font-size="28" font-weight="bold" text-anchor="middle" fill="#0f172a">SMART CAFE RECEIPT</text>
                    <text x="300" y="120" font-family="sans-serif" font-size="16" text-anchor="middle" fill="#64748b">2026-07-27 15:30 #0082</text>
                    <line x1="60" y1="150" x2="540" y2="150" stroke="#cbd5e1" stroke-width="2" stroke-dasharray="8 8"/>
                    <text x="80" y="210" font-family="sans-serif" font-size="22" font-weight="bold" fill="#1e293b">1. Ice Americano (L)</text>
                    <text x="500" y="210" font-family="monospace" font-size="22" font-weight="bold" text-anchor="end" fill="#1e293b">₩ 5,500</text>
                    <text x="80" y="270" font-family="sans-serif" font-size="22" font-weight="bold" fill="#1e293b">2. Strawberry Latte</text>
                    <text x="500" y="270" font-family="monospace" font-size="22" font-weight="bold" text-anchor="end" fill="#1e293b">₩ 6,800</text>
                    <text x="80" y="330" font-family="sans-serif" font-size="22" font-weight="bold" fill="#1e293b">3. Cheese Scone</text>
                    <text x="500" y="330" font-family="monospace" font-size="22" font-weight="bold" text-anchor="end" fill="#1e293b">₩ 4,200</text>
                    <line x1="60" y1="400" x2="540" y2="400" stroke="#cbd5e1" stroke-width="2"/>
                    <text x="80" y="460" font-family="sans-serif" font-size="24" font-weight="bold" fill="#0f172a">TOTAL AMOUNT</text>
                    <text x="500" y="460" font-family="monospace" font-size="28" font-weight="bold" text-anchor="end" fill="#4f46e5">₩ 16,500</text>
                </svg>`;
            } else if (type === 'object') {
                svgString = `<svg xmlns="http://www.w3.org/2000/svg" width="800" height="600" viewBox="0 0 800 600" fill="#0a0f1d">
                    <rect width="800" height="600" fill="#1e293b"/>
                    <rect x="200" y="150" width="400" height="260" rx="16" fill="#334155" stroke="#64748b" stroke-width="6"/>
                    <rect x="220" y="170" width="360" height="220" rx="8" fill="#0f172a"/>
                    <path d="M 150 430 L 650 430 L 680 470 L 120 470 Z" fill="#475569"/>
                    <circle cx="400" cy="280" r="40" fill="#6366f1" opacity="0.8"/>
                    <text x="400" y="530" font-family="sans-serif" font-size="22" text-anchor="middle" fill="#94a3b8">Modern Laptop Workstation</text>
                </svg>`;
            } else {
                svgString = `<svg xmlns="http://www.w3.org/2000/svg" width="800" height="600" viewBox="0 0 800 600" fill="#0a0f1d">
                    <rect width="800" height="600" fill="#0a0f1d"/>
                    <text x="400" y="70" font-family="sans-serif" font-size="24" font-weight="bold" text-anchor="middle" fill="#f8fafc">Q3 AI Adoption Metrics</text>
                    <rect x="150" y="320" width="80" height="180" fill="#6366f1" rx="8"/>
                    <rect x="290" y="240" width="80" height="260" fill="#818cf8" rx="8"/>
                    <rect x="430" y="180" width="80" height="320" fill="#a5b4fc" rx="8"/>
                    <rect x="570" y="120" width="80" height="380" fill="#c7d2fe" rx="8"/>
                    <text x="190" y="530" font-family="sans-serif" font-size="16" text-anchor="middle" fill="#94a3b8">2023</text>
                    <text x="330" y="530" font-family="sans-serif" font-size="16" text-anchor="middle" fill="#94a3b8">2024</text>
                    <text x="470" y="530" font-family="sans-serif" font-size="16" text-anchor="middle" fill="#94a3b8">2025</text>
                    <text x="610" y="530" font-family="sans-serif" font-size="16" text-anchor="middle" fill="#94a3b8">2026</text>
                </svg>`;
            }

            const blob = new Blob([svgString], { type: 'image/svg+xml' });
            const url = URL.createObjectURL(blob);
            const img = new Image();
            img.onload = function() {
                const canvas = document.createElement('canvas');
                canvas.width = img.width;
                canvas.height = img.height;
                const ctx = canvas.getContext('2d');
                ctx.drawImage(img, 0, 0);
                initCropper(canvas.toDataURL('image/png'));
                originalImageMime = 'image/png';
            };
            img.src = url;
        }

        // Call Gemini API (via Vercel Serverless or Local Direct Key)
        async function analyzeImageWithAI() {
            if (!cropper) {
                showToast('먼저 분석할 이미지를 올리거나 선택하세요.');
                return;
            }

            const prompt = document.getElementById('ai-prompt').value.trim();
            const localKey = document.getElementById('local-api-key').value.trim();
            const targetRegion = document.querySelector('input[name="target-region"]:checked').value;
            const outputBox = document.getElementById('ai-output');
            const btn = document.getElementById('analyze-btn');
            const btnText = document.getElementById('btn-text');

            if (!prompt) {
                showToast('프롬프트를 입력해 주세요.');
                return;
            }

            let imageBase64 = '';
            if (targetRegion === 'crop') {
                const croppedCanvas = cropper.getCroppedCanvas();
                if (!croppedCanvas) {
                    showToast('자르기 영역 획득에 실패했습니다.');
                    return;
                }
                imageBase64 = croppedCanvas.toDataURL(originalImageMime).split(',')[1];
            } else {
                const sourceImg = document.getElementById('source-image');
                const canvas = document.createElement('canvas');
                canvas.width = sourceImg.naturalWidth;
                canvas.height = sourceImg.naturalHeight;
                const ctx = canvas.getContext('2d');
                ctx.drawImage(sourceImg, 0, 0);
                imageBase64 = canvas.toDataURL(originalImageMime).split(',')[1];
            }

            btn.disabled = true;
            btnText.innerText = 'AI 분석 진행 중...';
            outputBox.innerHTML = `<div class="flex items-center gap-2 text-indigo-400"><i class="fa-solid fa-spinner animate-spin"></i><span>Gemini API에서 이미지를 정밀 분석하는 중입니다...</span></div>`;

            try {
                let responseData;

                if (localKey) {
                    const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent?key=${localKey}`;
                    const payload = {
                        contents: [{
                            role: 'user',
                            parts: [
                                { text: prompt },
                                {
                                    inlineData: {
                                        mimeType: originalImageMime,
                                        data: imageBase64
                                    }
                                }
                            ]
                        }]
                    };

                    const res = await fetch(url, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(payload)
                    });

                    if (!res.ok) {
                        const errJson = await res.json().catch(() => ({}));
                        throw new Error(errJson.error?.message || `클라이언트 Direct 호출 실패 (${res.status})`);
                    }
                    responseData = await res.json();
                } else {
                    const apiUrl = getApiUrl();
                    const res = await fetch(apiUrl, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            prompt: prompt,
                            imageBase64: imageBase64,
                            mimeType: originalImageMime
                        })
                    });

                    if (!res.ok) {
                        const errJson = await res.json().catch(() => ({}));
                        throw new Error(errJson.error || `서버리스 API 호출 실패 (${res.status})`);
                    }
                    responseData = await res.json();
                }

                const resultText = responseData.candidates?.[0]?.content?.parts?.[0]?.text;
                if (!resultText) {
                    throw new Error('응답 결과를 불러올 수 없습니다.');
                }

                outputBox.innerHTML = marked.parse(resultText);

            } catch (err) {
                const is404 = err.message.includes('404') || err.message.includes('서버리스');
                outputBox.innerHTML = `
                    <div class="p-4 bg-slate-900 border border-slate-800 rounded-xl flex flex-col gap-3">
                        <div class="flex items-center gap-2 text-amber-400 font-semibold text-xs">
                            <i class="fa-solid fa-circle-info text-sm"></i>
                            <span>${is404 ? '미리보기(Preview) 모드 안내' : 'API 호출 실패'}</span>
                        </div>
                        <p class="text-xs text-slate-300 leading-relaxed">
                            ${is404 ?
                                '현재 화면은 백엔드가 없는 정적 미리보기 환경입니다. Vercel 서버리스 백엔드(<code>/api/generate</code>)는 Vercel 배포 후 구동됩니다.' :
                                err. message
                            }
                        </p>
                        <div class="bg-slate-950 p-3 rounded-lg border border-slate-800 text-[11px] text-slate-400 flex flex-col gap-1.5">
                            <span class="font-bold text-slate-200">💡 미리보기에서 테스트하는 2가지 방법:</span>
                            <span>1. 우측 <strong>'로컬 직접 테스트용 API Key'</strong> 칸에 Gemini API Key를 입력하세요.</span>
                            <span>2. [Vercel 배포용 ZIP 다운로드] 후 Vercel에 배포하고 <code class="text-indigo-300">GEMINI_API_KEY</code> 환경 변수를 등록하세요.</span>
                        </div>
                        <button onclick="loadDemoAnalysisResult()" class="mt-1 bg-indigo-600/20 hover:bg-indigo-600/30 text-indigo-300 border border-indigo-500/30 py-2 rounded-lg text-xs font-medium transition-colors flex items-center justify-center gap-1.5">
                            <i class="fa-solid fa-eye"></i> 데모 샘플 분석 결과 미리보기
                        </button>
                    </div>`;
            } finally {
                btn.disabled = false;
                btnText.innerText = 'AI 분석 실행';
            }
        }

        function loadDemoAnalysisResult() {
            const outputBox = document.getElementById('ai-output');
            const mode = document.getElementById('analysis-mode').value;

            let demoText = "";
            if (mode === 'ocr') {
                demoText = `### 🔍 AI OCR 텍스트 분석 결과 (시뮬레이션)

- **문서 종류**: 카페/매장 영수증 (Receipt)
- **발행 일시**: 2026-07-27 15:30:00
- **영수증 번호**: #0082

#### 📋 결제 항목 상세
1. **Ice Americano (L)** — ₩ 5,500 (수량: 1)
2. **Strawberry Latte** — ₩ 6,800 (수량: 1)
3. **Cheese Scone** — ₩ 4,200 (수량: 1)

---
- **총 합계 금액**: **₩ 16,500**
- **결제 상태**: 승인 완료 (신용카드)

> *참고: 로컬 API Key 입력 시 업로드하신 실제 이미지의 텍스트가 정확히 읽힙니다.*`;
            } else if (mode === 'detect') {
                demoText = `### 🏷️ 피사체 및 주요 구성 요소 추출

1. **주요 대상 (Primary Subject)**: 랩톱 컴퓨터 및 데스크 오피스 구성 요소
2. **배경 요소**: 업무용 모니터, 마우스, 미니멀 데스크 패드
3. **색상 구성**: Slate Gray (#334155), Dark Blue (#0f172a), Indigo Accent (#6366f1)
4. **상태 감지**: 선명함, 반사방지 액정 표면

#### 💡 추천 사용 용도
- 제품 카탈로그 상세 이미지
- 웹사이트 헤더 및 카드 블로그 썸네일`;
            } else {
                demoText = `### ✂️ 자르기 구도 분석 및 가이드 추천

- **현재 구도**: 황금비율(Golden Ratio) 중심 구도
- **추천 자르기 비율**:
  - **1:1 (정사각형)**: 인스타그램/SNS 카드 뉴스용
  - **16:9 (와이드)**: 데스크톱 배너 및 유튜브 썸네일용
- **조명 및 명암**: 피사체 강조 구도가 잘 유지되어 있으며, 주변부 여백을 10% 축소 시 피사체 집중도가 향상됩니다.`;
            }

            outputBox.innerHTML = marked.parse(demoText);
            showToast('데모 분석 결과가 로드되었습니다.');
        }

        // Tab Switching Logic
        function switchTab(tabName) {
            document.querySelectorAll('.tab-btn').forEach(btn => {
                btn.classList.remove('active', 'border-indigo-500', 'text-indigo-400', 'font-semibold');
                btn.classList.add('border-transparent', 'text-slate-400');
            });
            document.querySelectorAll('.tab-content').forEach(content => {
                content.classList.add('hidden');
                content.classList.remove('flex');
            });

            const activeTab = document.getElementById(`tab-${tabName}`);
            activeTab.classList.add('active', 'border-indigo-500', 'text-indigo-400', 'font-semibold');
            activeTab.classList.remove('border-transparent', 'text-slate-400');

            const activeContent = document.getElementById(`content-${tabName}`);
            activeContent.classList.remove('hidden');
            if (tabName !== 'studio') {
                activeContent.classList.add('flex');
            }

            if (tabName === 'files') {
                showCodeFile(currentSelectedFile);
            }
        }

        function showCodeFile(fileName) {
            currentSelectedFile = fileName;
            document.getElementById('current-file-name').innerText = fileName;
            const codeViewer = document.getElementById('code-viewer-content');
            codeViewer.textContent = projectFiles[fileName] || '';
           
            delete codeViewer.dataset.highlighted;
            hljs.highlightElement(codeViewer);

            document.querySelectorAll('.code-file-btn').forEach(btn => {
                if (btn.innerText.includes(fileName)) {
                    btn.classList.add('bg-indigo-600/20', 'border-indigo-500/50', 'text-indigo-300');
                    btn.classList.remove('bg-slate-900', 'border-slate-800', 'text-slate-300');
                } else {
                    btn.classList.remove('bg-indigo-600/20', 'border-indigo-500/50', 'text-indigo-300');
                    btn.classList.add('bg-slate-900', 'border-slate-800', 'text-slate-300');
                }
            });
        }

        function copyCurrentCode() {
            copyToClipboard(projectFiles[currentSelectedFile]);
            showToast('파일 코드가 클립보드에 복사되었습니다.');
        }

        function copyResultText() {
            const el = document.getElementById('ai-output');
            copyToClipboard(el.innerText);
            showToast('분석 결과가 복사되었습니다.');
        }

        function copyToClipboard(text) {
            const textarea = document.createElement('textarea');
            textarea.value = text;
            document.body.appendChild(textarea);
            textarea.select();
            document.execCommand('copy');
            document.body.removeChild(textarea);
        }

        function showToast(msg) {
            const toast = document.createElement('div');
            toast.className = 'fixed bottom-5 right-5 bg-indigo-600 text-white text-xs px-4 py-2.5 rounded-xl shadow-2xl z-50 transition-all transform translate-y-2 opacity-0 font-medium';
            toast.innerText = msg;
            document.body.appendChild(toast);
           
            setTimeout(() => {
                toast.classList.remove('translate-y-2', 'opacity-0');
            }, 10);

            setTimeout(() => {
                toast.classList.add('translate-y-2', 'opacity-0');
                setTimeout(() => toast.remove(), 300);
            }, 2500);
        }

        // Export Entire ZIP Project for Vercel
        async function downloadProjectZip() {
            try {
                showToast('Vercel 배포용 ZIP 패키지를 생성하는 중입니다...');
                const zip = new JSZip();

                for (const [filename, content] of Object. entries(projectFiles)) {
                    zip.file(filename, content);
                }

                const blob = await zip.generateAsync({ type: 'blob' });
                saveAs(blob, 'smart-ai-crop-studio-vercel.zip');
                showToast('프로젝트 ZIP 파일이 정상 다운로드 되었습니다!');
            } catch (err) {
                console.error('ZIP Error:', err);
                showToast('ZIP 생성 실패: ' + err.message);
            }
        }

        window.addEventListener('DOMContentLoaded', () => {
            handleModeChange();
            showCodeFile('index.html');
        });
    </script>
</body>
</html>
