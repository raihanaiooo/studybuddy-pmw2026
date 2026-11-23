/** Dialog aplikasi (GlobalUiManager menimpa window.alert/prompt menjadi versi berjanji). Dibungkus agar bertipe. */
type AsyncAlert = (message: string) => Promise<void>;
type AsyncPrompt = (message: string) => Promise<string | null>;

export const showAlert: AsyncAlert = (message) => (window.alert as unknown as AsyncAlert)(message);
export const showPrompt: AsyncPrompt = (message) => (window.prompt as unknown as AsyncPrompt)(message);
