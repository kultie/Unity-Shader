using System.Linq;
using System.Collections.Generic;
using UnityEngine;
public class PostProcessing : MonoBehaviour
{
    public Material material;


    private void Update()
    {
        Vector3 pos = Camera.main.ScreenToViewportPoint(Input.mousePosition); //0~1 mouse position
        //Vector3 pos = Camera.main.WorldToScreenPoint(Input.mousePosition);
        if (Input.GetMouseButtonDown(0)) {
            material.SetVector("_Position", pos);
            material.SetFloat("_StartWave", 1);
            material.SetFloat("_CurrentTime", Time.timeSinceLevelLoad);
        }
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        int passCount = material.passCount;
        if (passCount > 1)
        {
            RenderTexture tmp = RenderTexture.GetTemporary(source.width, source.height);
            RenderTexture tmp2 = RenderTexture.GetTemporary(source.width, source.height);
            Graphics.Blit(source, tmp, material, 0);
            if (passCount == 2)
            {
                Graphics.Blit(tmp, destination, material, 1);
            }
            else {
                for (int i = 1; i < passCount-1; i++)
                {
                    Graphics.Blit(tmp, tmp2, material, i);
                    tmp = tmp2;
                }
                Graphics.Blit(tmp2, destination, material,passCount - 1);
            }
            //Graphics.Blit(source, tmp, material, 0);
            //Graphics.Blit(tmp, destination, material, 1);
            RenderTexture.ReleaseTemporary(tmp);
            RenderTexture.ReleaseTemporary(tmp2);
        }
        else {
            Graphics.Blit(source, destination, material);
        }
    }
}

