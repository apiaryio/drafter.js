interface DrafterValidateOptions { 
  json?: boolean,
  requireBlueprintName?: boolean,
}

interface DrafterParseOptions extends DrafterValidateOptions {
  generateSourceMap?: boolean,
  type?: string
}

interface DrafterStatic {
  parse(code: string, options: DrafterParseOptions, callback: (err: Error, parseResult : any) => void)
  validate(code: string, options: DrafterValidateOptions, callback: (err: Error, parseResult : any) => void)
  parseSync(code: string, options: DrafterParseOptions) : any
  validateSync(code: string, options: DrafterValidateOptions) : any
}

declare const Drafter: DrafterStatic;

export default Drafter;
