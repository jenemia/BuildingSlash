# BuildingSlash

GitHub Pages에서 바로 실행되는 Godot Web 빌드 프로젝트다.

라이브 URL:
<https://jenemia.github.io/BuildingSlash/>

## Web Build

macOS에서 `godot` PATH를 잡아 두었고, 웹 export는 아래 명령으로 다시 만들 수 있다.

```bash
./scripts/build_web.sh
```

스크립트 동작:

- macOS에서는 `/Applications/Godot.app`를 우선 사용한다.
- `Godot.app`이 없으면 즉시 실패한다.
- export templates가 없을 때만 현재 설치된 Godot 버전에 맞는 템플릿을 내려받아 설치한다.
- export 결과물은 저장소 루트에 생성된다.
- `.nojekyll`을 함께 만들어 GitHub Pages가 정적 파일을 그대로 서빙하게 한다.

주요 산출물:

- `index.html`
- `index.js`
- `index.wasm`
- `index.pck`
- `index.png`
- `index.icon.png`
- `index.apple-touch-icon.png`
- `index.audio.worklet.js`
- `index.audio.position.worklet.js`

## GitHub Pages

이 저장소는 현재 `main` 브랜치 루트 콘텐츠를 GitHub Pages로 서빙한다. 그래서 웹 export 산출물을 루트에 두면 별도 액션 전환 없이 바로 사이트에 반영된다.
