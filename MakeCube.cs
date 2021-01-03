using UnityEngine;
using System.Collections.Generic;

[RequireComponent(typeof (MeshFilter))]
[RequireComponent(typeof (MeshRenderer))]
public class MakeCube : MonoBehaviour {

    float xs = 0.25f;
    float ys = 0.25f;
    float zs = 0.25f;

    float xo;
    float yo;
    float zo;

    void Start () {
        xo = -xs / 2.0f;
        yo = -ys / 2.0f + 1.6f;
        zo = -zs / 2.0f;

        CreateCube ();
	}

	private void CreateCube () {
		Vector3[] vertices = {
			new Vector3 (xo+0,  yo+ 0, zo+ 0),
			new Vector3 (xo+xs, yo+ 0, zo+ 0),
			new Vector3 (xo+xs, yo+ys, zo+ 0),
			new Vector3 (xo+0,  yo+ys, zo+ 0),
			new Vector3 (xo+0,  yo+ys, zo+zs),
			new Vector3 (xo+xs, yo+ys, zo+zs),
			new Vector3 (xo+xs, yo+ 0, zo+zs),
			new Vector3 (xo+0,  yo+ 0, zo+zs),
		};

		int[] triangles = {
			0, 2, 1, //face front
			0, 3, 2,
			2, 3, 4, //face top
			2, 4, 5,
			1, 2, 5, //face right
			1, 5, 6,
			0, 7, 4, //face left
			0, 4, 3,
			5, 4, 7, //face back
			5, 7, 6,
			0, 6, 7, //face bottom
			0, 1, 6
		};
		
		Mesh mesh = GetComponent<MeshFilter> ().mesh;
		mesh.Clear ();
		mesh.vertices = vertices;
		mesh.triangles = triangles;
		mesh.Optimize ();
		mesh.RecalculateNormals ();


		//--- Add material
		GetComponent<Renderer>().material = (Material)Resources.Load("Materials/VolumeRenderMaterial");

		//--- Sets the local scale of an object
		Vector3 local = transform.localScale;
		transform.localScale = new Vector3(0.5f,1f,1f);

	}
}