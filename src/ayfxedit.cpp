//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
#include <tchar.h>
//---------------------------------------------------------------------------
USEFORM("UnitMain.cpp", FormMain);
USEFORM("UnitAYChannelSelect.cpp", FormAyChn);
USEFORM("UnitPiano.cpp", FormPiano);
USEFORM("UnitSNChannelSelect.cpp", FormSnChn);
USEFORM("UnitVT2Instrument.cpp", FormVortexExp);
//---------------------------------------------------------------------------
int WINAPI _tWinMain(HINSTANCE, HINSTANCE, LPTSTR, int)
{
	try
	{
		Application->Initialize();
		Application->MainFormOnTaskBar = true;
		Application->CreateForm(__classid(TFormMain), &FormMain);
		Application->CreateForm(__classid(TFormAyChn), &FormAyChn);
		Application->CreateForm(__classid(TFormPiano), &FormPiano);
		Application->CreateForm(__classid(TFormSnChn), &FormSnChn);
		Application->CreateForm(__classid(TFormVortexExp), &FormVortexExp);
		Application->Run();
	}
	catch (Exception &exception)
	{
		Application->ShowException(&exception);
	}
	catch (...)
	{
		try
		{
			throw Exception("");
		}
		catch (Exception &exception)
		{
			Application->ShowException(&exception);
		}
	}
	return 0;
}
//---------------------------------------------------------------------------
