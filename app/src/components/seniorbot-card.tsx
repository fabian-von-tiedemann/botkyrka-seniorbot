"use client";

interface SeniorbotCardProps {
  onOpenChat: () => void;
}

export function SeniorbotCard({ onOpenChat }: SeniorbotCardProps) {
  return (
    <div className="sv-vertical sv-layout bot-main__block-left--blue sv-skip-spacer">
      <div className="sv-vertical sv-layout sv-skip-spacer sv-decoration-content">
        <div className="sv-text-portlet sv-use-margins sv-skip-spacer">
          <div className="sv-text-portlet-content">
            <h2 className="subheading2">Har du frågor om äldreomsorgen?</h2>
          </div>
        </div>
        <div className="sv-text-portlet sv-use-margins">
          <div className="sv-text-portlet-content">
            <p className="normal">
              Prata med Seniorbot – vår digitala assistent kan svara på frågor
              om hemtjänst, avgifter, boenden och mer.
            </p>
          </div>
        </div>
        <div className="sv-text-portlet sv-use-margins">
          <div className="sv-vertical sv-layout bot-main__cerise-btn sv-skip-spacer">
            <div className="sv-vertical sv-layout sv-skip-spacer sv-decoration-content">
              <div className="sv-text-portlet-content">
                <p className="normal">
                  <a
                    href="#"
                    onClick={(e) => {
                      e.preventDefault();
                      onOpenChat();
                    }}
                  >
                    Ställ en fråga
                  </a>
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
