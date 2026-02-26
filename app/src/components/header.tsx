export function Header() {
  return (
    <div className="sv-vertical sv-layout bot-header__header-container sv-skip-spacer sv-template-layout">
    <header
      aria-label="Sidhuvud"
      className="sv-vertical sv-layout bot-header sv-skip-spacer sv-template-layout"
    >
      {/* Desktop Header */}
      <div className="sv-vertical sv-layout bot-header__desktop sv-template-layout">
        {/* Skip to content */}
        <a
          href="#main-content"
          accessKey="s"
          className="main-content visuallyhidden is-focusable"
        >
          Hoppa till huvudinnehållet
        </a>

        <div className="sv-fixed-fluid-grid sv-grid-12-kolumner sv-layout sv-template-layout">
          <div className="sv-row sv-layout bot-header__desktop--search sv-skip-spacer sv-template-layout">
            {/* Logo column */}
            <div className="sv-layout sv-skip-spacer sv-column-6 sv-template-layout">
              <div className="sv-vertical sv-layout sv-skip-spacer sv-template-layout">
                <a href="/" className="bot-header__desktop-logotype">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img
                    src="/botkyrka-logo.svg"
                    alt="Länk till startsidan för Botkyrka"
                    className="c14629"
                    style={{ width: "277px" }}
                  />
                </a>
              </div>
            </div>

            {/* Search column */}
            <div className="sv-layout sv-column-6 sv-template-layout">
              <div className="sv-vertical sv-layout bot-header__search sv-skip-spacer sv-template-layout">
                <form
                  method="get"
                  action="#"
                  className="sv-nomargin"
                  aria-label="Sökfunktion för webbplatsen"
                  role="search"
                >
                  <div>
                    <label className="sv-visuallyhidden" htmlFor="search-input">
                      Vad vill du söka på?
                    </label>
                    <input
                      id="search-input"
                      className="bot-header__service-nav--search-input normal sv-vamiddle c14624"
                      type="text"
                      name="query"
                      placeholder="Ange sökord"
                    />
                    <input
                      type="submit"
                      className="bot-header__service-nav--search-input-button normal sv-vamiddle"
                      name="submitButton"
                      value="Sök"
                    />
                  </div>
                </form>
              </div>

              {/* Service navigation */}
              <div className="sv-vertical sv-layout bot-header__service-nav sv-template-layout c14618">
                <div className="c14622">
                  {/* Sök button */}
                  <button
                    className="bot-header__service-nav--search-button"
                    aria-expanded="false"
                  >
                    <span className="search">
                      <svg
                        version="1.1"
                        xmlns="http://www.w3.org/2000/svg"
                        x="0px"
                        y="0px"
                        viewBox="0 0 27 27"
                        className="c14623"
                      >
                        <g>
                          <path
                            className="st0"
                            d="M26.24,22.96l-4.6-4.6c-0.4-0.4-0.94-0.63-1.52-0.67l-0.06,0l-1.85-1.85l0.07-0.1
                            c2.73-3.97,2.25-9.31-1.16-12.72c-1.88-1.88-4.39-2.92-7.06-2.92c-2.67,0-5.18,1.04-7.06,2.92L2.96,3.06
                            c-1.86,1.88-2.88,4.37-2.88,7.02c0,2.67,1.04,5.18,2.92,7.06c1.88,1.88,4.38,2.92,7.05,2.92c2.04,0,4-0.61,5.67-1.76l0.1-0.07
                            l1.85,1.85l0,0.06c0.03,0.58,0.27,1.12,0.66,1.51l4.6,4.6c0.44,0.44,1.02,0.68,1.65,0.68c0.62,0,1.21-0.24,1.65-0.68
                            C27.14,25.35,27.14,23.87,26.24,22.96z M10.06,19.24c-2.45,0-4.75-0.95-6.48-2.69c-3.57-3.57-3.57-9.39,0-12.96l0.05-0.04
                            c1.73-1.7,4.01-2.64,6.43-2.64c2.44,0,4.74,0.95,6.48,2.69c1.73,1.73,2.69,4.03,2.69,6.48c0,2.45-0.95,4.75-2.69,6.48
                            C14.81,18.29,12.51,19.24,10.06,19.24z"
                          />
                        </g>
                      </svg>
                      Sök{" "}
                      <span className="visuallyhidden">på webbplatsen</span>
                    </span>
                  </button>
                </div>

                <div className="c14621">
                  {/* Lyssna */}
                  <a href="#" id="bapluslogo">
                    <svg
                      height="32px"
                      version="1.1"
                      xmlns="http://www.w3.org/2000/svg"
                      x="0px"
                      y="0px"
                      viewBox="0 0 28 27"
                      className="c14631"
                    >
                      <g>
                        <path
                          className="st0"
                          d="M8.64,1.09c-4.28,0-7.85,3.34-8.29,7.77C0.31,9.15,0.52,9.41,0.81,9.44C1.1,9.46,1.35,9.26,1.38,8.97
                          c0.4-3.9,3.52-6.84,7.26-6.84c4.03,0,7.3,3.43,7.3,7.66c0,2.75-1.54,5.28-4.21,6.94c-4.08,2.53-4.4,4.45-4.4,4.98
                          c0,1.82-1.33,3.3-2.96,3.3c-1.5,0-2.77-1.25-2.94-2.92c-0.03-0.28-0.28-0.49-0.57-0.46c-0.29,0.03-0.49,0.29-0.46,0.57
                          c0.23,2.19,1.94,3.85,3.97,3.85c2.2,0,4-1.95,4-4.34c0-0.07,0.04-1.7,3.9-4.1c2.99-1.85,4.71-4.71,4.71-7.83
                          C16.98,4.99,13.24,1.09,8.64,1.09z"
                        />
                        <path
                          className="st0"
                          d="M5.58,15.95c-0.29,0-0.52,0.23-0.52,0.52c0,0.29,0.23,0.52,0.52,0.52c1.59,0,2.88-1.53,2.88-3.4
                          c0-1.29-0.6-2.45-1.57-3.03C6.4,10.26,6.1,9.79,6.1,9.28V9.12c0-1.52,1.22-2.76,2.73-2.76s2.73,1.24,2.73,2.76
                          c0,0.29,0.23,0.52,0.52,0.52c0.29,0,0.52-0.23,0.52-0.52c0-2.09-1.69-3.8-3.77-3.8s-3.77,1.7-3.77,3.8v0.16
                          c0,0.87,0.48,1.68,1.29,2.17c0.65,0.39,1.07,1.23,1.07,2.14C7.42,14.89,6.6,15.95,5.58,15.95z"
                        />
                        <path
                          className="st0"
                          d="M23.68,2.52c-0.11-0.09-0.25-0.13-0.38-0.13c-0.2,0-0.38,0.09-0.5,0.25c-0.21,0.28-0.16,0.68,0.12,0.89
                          c2.12,1.63,3.43,4.38,3.49,7.38c0.06,3.22-1.34,6.23-3.66,7.86c-0.14,0.1-0.23,0.24-0.26,0.41c-0.03,0.17,0.01,0.33,0.1,0.47
                          c0.1,0.15,0.27,0.24,0.45,0.26c0.03,0,0.05,0,0.08,0c0.13,0,0.25-0.04,0.36-0.13c2.66-1.87,4.28-5.29,4.21-8.92
                          C27.59,7.5,26.1,4.38,23.68,2.52z"
                        />
                        <path
                          className="st0"
                          d="M20.47,7c-0.11-0.07-0.23-0.11-0.36-0.11c-0.21,0-0.4,0.1-0.52,0.27c-0.1,0.14-0.13,0.3-0.1,0.47
                          c0.03,0.17,0.12,0.31,0.26,0.41c0.97,0.68,1.57,1.82,1.59,3.05c0.03,1.33-0.62,2.58-1.69,3.26c-0.29,0.19-0.38,0.58-0.19,0.87
                          c0.1,0.16,0.27,0.27,0.46,0.29c0.03,0,0.05,0,0.08,0c0.12,0,0.23-0.03,0.33-0.1c1.44-0.91,2.31-2.58,2.27-4.36
                          C22.58,9.43,21.78,7.9,20.47,7z"
                        />
                      </g>
                    </svg>
                    Lyssna{" "}
                    <span className="visuallyhidden">
                      på webbplatsen genom att aktivera Talande Webb
                    </span>
                  </a>
                </div>

                <div className="c14635">
                  {/* Kontakt */}
                  <a href="https://www.botkyrka.se/kommun-och-politik/kontakt" id="contactIcon">
                    <svg
                      height="32px"
                      className="c14617"
                      version="1.1"
                      viewBox="0 0 512 512"
                      width="512px"
                      xmlns="http://www.w3.org/2000/svg"
                    >
                      <g>
                        <path
                          className="st0"
                          d="M434.158,333.092c-9.802-16.148-35.668-23.274-50.215-26.086c-26.549-5.13-60.764-4.74-77.348,7.698
                          c-5.459,4.097-8.178,12.563-8.813,27.452c-0.084,1.962-0.121,3.878-0.131,5.693c-28.178-10.883-54.189-27.118-76.389-47.683
                          l-9.749-9.694c-20.652-22.044-36.964-47.872-47.903-75.845c1.829-0.009,3.76-0.046,5.738-0.129
                          c14.942-0.631,23.439-3.33,27.551-8.75c12.455-16.417,12.906-50.315,7.828-76.626c-2.815-14.591-9.979-40.531-26.315-50.335
                          c-16.252-9.754-41.371-7.401-51.417-5.935c-20.725,3.021-37.967,10.344-46.124,19.586c-7.108,8.055-9.605,31.042-10.348,40.55
                          c-0.02,0.25-0.027,0.507-0.023,0.758c1.223,77.447,31.015,151.402,83.886,208.214c0.071,0.075,0.143,0.181,0.216,0.254
                          l14.822,14.801c0.073,0.073,0.147,0.271,0.224,0.339C226.771,409.916,301.107,439,378.965,441c0.041,0,0.083,0,0.124,0
                          c0.206,0,0.412-0.258,0.618-0.273c9.55-0.739,32.636-3.469,40.721-10.523c9.302-8.116,16.671-25.277,19.713-45.907
                          C441.615,374.294,443.984,349.282,434.158,333.092z"
                        />
                      </g>
                    </svg>
                    <p className="bot-header__desktop--contact-us-text">
                      Kontakt
                    </p>
                  </a>
                </div>

                <div className="c14635">
                  {/* Translate / Suomi */}
                  <div id="languageButtonDiv">
                    <a href="https://www.botkyrka.se/kommun-och-politik/press-och-kommunikation/translate" id="languageButton">
                      <svg
                        version="1.1"
                        xmlns="http://www.w3.org/2000/svg"
                        x="0px"
                        y="0px"
                        viewBox="0 0 382.169 382.169"
                        className="c14628"
                      >
                        <path
                          className="st0"
                          d="M191.084,0C85.72,0,0,85.72,0,191.084s85.72,191.084,191.084,191.084c105.365,0,191.084-85.72,191.084-191.084
                          S296.449,0,191.084,0z M366.998,183.584H328.06c-0.993-36.182-9.156-70.613-23.534-100.029c5.258-3.894,10.338-8.08,15.227-12.542
                          C347.554,100.786,365.169,140.176,366.998,183.584z"
                        />
                      </svg>
                    </a>
                  </div>
                  <div id="translateLinks">
                    <a href="https://www.botkyrka.se/kommun-och-politik/press-och-kommunikation/translate" id="translateLink">
                      <p className="bot-header__desktop--translate-text">
                        Translate
                      </p>
                    </a>
                    <p className="pipe">|</p>
                    <a href="#" id="suomiLink">
                      <p className="bot-header__desktop--translate-text">
                        Suomi
                      </p>
                    </a>
                  </div>
                </div>

                <div className="c14621">
                  {/* Meny */}
                  <span className="visuallyhidden">Öppna desktopmenyn</span>
                  <a
                    href="#"
                    className="bot-header__service-nav--menu"
                    aria-label="Öppna menyn"
                    role="button"
                    aria-expanded="false"
                  >
                    <span className="icon icon-bars" aria-hidden="true" />
                    Meny
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Mobile Header */}
      <div className="sv-vertical sv-layout bot-header__mobile sv-template-layout" />
    </header>
    </div>
  );
}
